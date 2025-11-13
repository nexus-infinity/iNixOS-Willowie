{ config, lib, pkgs, ... }:

with lib;

{
  # Notion AI Connector Service Module
  # Synchronizes knowledge between jnana chakra and Notion databases
  # Provides bidirectional sync for universal knowledge management
  
  options.services.notion-ai-connector = {
    enable = mkEnableOption "Notion AI Connector for knowledge synchronization";
    
    apiKey = mkOption {
      type = types.str;
      default = "";
      description = ''
        Notion API integration token.
        Can be obtained from https://www.notion.so/my-integrations
        For security, consider using environment variables or secrets management.
      '';
    };
    
    databaseId = mkOption {
      type = types.str;
      default = "";
      description = ''
        Notion database ID to sync with jnana chakra.
        This is the UUID from the database URL.
      '';
    };
    
    syncInterval = mkOption {
      type = types.int;
      default = 300;
      description = ''
        Sync interval in seconds (default: 300 = 5 minutes).
        How often to check for changes and synchronize.
      '';
    };
    
    jnanaPath = mkOption {
      type = types.str;
      default = "/jnana/akasha/eternal_records";
      description = ''
        Path to jnana chakra knowledge repository.
        This is where knowledge is stored locally.
      '';
    };
    
    mqttBroker = mkOption {
      type = types.str;
      default = "mqtt://localhost:1883";
      description = ''
        MQTT broker URL for real-time updates.
        Used to publish sync events and receive triggers.
      '';
    };
    
    mqttTopic = mkOption {
      type = types.str;
      default = "jnana/notion/sync";
      description = ''
        MQTT topic for Notion sync events.
        Publishes sync status and listens for sync triggers.
      '';
    };
    
    port = mkOption {
      type = types.port;
      default = 8084;
      description = ''
        HTTP API port for manual sync triggers and status checks.
      '';
    };
    
    logLevel = mkOption {
      type = types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL" ];
      default = "INFO";
      description = ''
        Logging level for the connector service.
      '';
    };
  };

  config = mkIf config.services.notion-ai-connector.enable {
    # Create notion-ai user for service isolation
    users.users.notion-ai = {
      isSystemUser = true;
      group = "notion-ai";
      description = "Notion AI Connector service user";
    };
    
    users.groups.notion-ai = {};
    
    # Ensure jnana directory exists with proper permissions
    systemd.tmpfiles.rules = [
      "d ${config.services.notion-ai-connector.jnanaPath} 0750 notion-ai notion-ai -"
      "d /var/lib/notion-ai-connector 0750 notion-ai notion-ai -"
      "d /var/log/notion-ai-connector 0750 notion-ai notion-ai -"
    ];
    
    # Python connector script
    environment.systemPackages = [
      (pkgs.python3.withPackages (ps: with ps; [
        requests
        paho-mqtt
        flask
      ]))
    ];
    
    # Systemd service definition
    systemd.services.notion-ai-connector = {
      description = "Notion AI Connector - Knowledge Synchronization Bridge";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      environment = {
        NOTION_API_KEY = config.services.notion-ai-connector.apiKey;
        NOTION_DATABASE_ID = config.services.notion-ai-connector.databaseId;
        SYNC_INTERVAL = toString config.services.notion-ai-connector.syncInterval;
        JNANA_PATH = config.services.notion-ai-connector.jnanaPath;
        MQTT_BROKER = config.services.notion-ai-connector.mqttBroker;
        MQTT_TOPIC = config.services.notion-ai-connector.mqttTopic;
        HTTP_PORT = toString config.services.notion-ai-connector.port;
        LOG_LEVEL = config.services.notion-ai-connector.logLevel;
        LOG_DIR = "/var/log/notion-ai-connector";
      };
      
      serviceConfig = {
        Type = "simple";
        User = "notion-ai";
        Group = "notion-ai";
        Restart = "on-failure";
        RestartSec = "30s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          config.services.notion-ai-connector.jnanaPath
          "/var/lib/notion-ai-connector"
          "/var/log/notion-ai-connector"
        ];
        
        # Connector script (inline for now, can be extracted to separate file)
        ExecStart = pkgs.writeShellScript "notion-ai-connector" ''
          #!${pkgs.python3}/bin/python3
          import os
          import sys
          import json
          import time
          import logging
          from datetime import datetime
          from pathlib import Path
          
          try:
              import requests
              import paho.mqtt.client as mqtt
              from flask import Flask, jsonify, request
              from threading import Thread
          except ImportError as e:
              print(f"Missing required Python packages: {e}")
              print("Install with: pip install requests paho-mqtt flask")
              sys.exit(1)
          
          # Configuration from environment
          NOTION_API_KEY = os.getenv('NOTION_API_KEY', '')
          NOTION_DATABASE_ID = os.getenv('NOTION_DATABASE_ID', '')
          SYNC_INTERVAL = int(os.getenv('SYNC_INTERVAL', '300'))
          JNANA_PATH = Path(os.getenv('JNANA_PATH', '/jnana/akasha/eternal_records'))
          MQTT_BROKER = os.getenv('MQTT_BROKER', 'mqtt://localhost:1883')
          MQTT_TOPIC = os.getenv('MQTT_TOPIC', 'jnana/notion/sync')
          HTTP_PORT = int(os.getenv('HTTP_PORT', '8084'))
          LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
          LOG_DIR = Path(os.getenv('LOG_DIR', '/var/log/notion-ai-connector'))
          
          # Setup logging
          log_file = LOG_DIR / 'connector.log'
          logging.basicConfig(
              level=getattr(logging, LOG_LEVEL),
              format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
              handlers=[
                  logging.FileHandler(log_file),
                  logging.StreamHandler()
              ]
          )
          logger = logging.getLogger('notion-ai-connector')
          
          # Notion API base URL
          NOTION_API_BASE = 'https://api.notion.com/v1'
          NOTION_VERSION = '2022-06-28'
          
          class NotionConnector:
              def __init__(self):
                  self.headers = {
                      'Authorization': f'Bearer {NOTION_API_KEY}',
                      'Notion-Version': NOTION_VERSION,
                      'Content-Type': 'application/json'
                  }
                  self.mqtt_client = None
                  self.last_sync = None
                  self.sync_count = 0
                  
              def validate_config(self):
                  """Validate that required configuration is present"""
                  if not NOTION_API_KEY:
                      logger.warning("NOTION_API_KEY not configured - running in stub mode")
                      return False
                  if not NOTION_DATABASE_ID:
                      logger.warning("NOTION_DATABASE_ID not configured - running in stub mode")
                      return False
                  return True
                  
              def setup_mqtt(self):
                  """Setup MQTT client for real-time events"""
                  try:
                      # Parse MQTT broker URL
                      broker_url = MQTT_BROKER.replace('mqtt://', '')
                      host = broker_url.split(':')[0] if ':' in broker_url else broker_url
                      port = int(broker_url.split(':')[1]) if ':' in broker_url else 1883
                      
                      self.mqtt_client = mqtt.Client()
                      self.mqtt_client.on_connect = self.on_mqtt_connect
                      self.mqtt_client.on_message = self.on_mqtt_message
                      self.mqtt_client.connect(host, port, 60)
                      self.mqtt_client.loop_start()
                      logger.info(f"Connected to MQTT broker at {host}:{port}")
                  except Exception as e:
                      logger.warning(f"Could not connect to MQTT broker: {e}")
                      
              def on_mqtt_connect(self, client, userdata, flags, rc):
                  """MQTT connection callback"""
                  logger.info(f"MQTT connected with result code {rc}")
                  client.subscribe(f"{MQTT_TOPIC}/trigger")
                  
              def on_mqtt_message(self, client, userdata, msg):
                  """MQTT message callback"""
                  logger.info(f"Received MQTT message on {msg.topic}: {msg.payload}")
                  if msg.topic == f"{MQTT_TOPIC}/trigger":
                      self.sync_knowledge()
                      
              def query_notion_database(self):
                  """Query Notion database for entries"""
                  if not self.validate_config():
                      return []
                      
                  try:
                      url = f"{NOTION_API_BASE}/databases/{NOTION_DATABASE_ID}/query"
                      response = requests.post(url, headers=self.headers, json={})
                      response.raise_for_status()
                      data = response.json()
                      logger.info(f"Retrieved {len(data.get('results', []))} entries from Notion")
                      return data.get('results', [])
                  except Exception as e:
                      logger.error(f"Failed to query Notion database: {e}")
                      return []
                      
              def save_to_jnana(self, entries):
                  """Save Notion entries to jnana chakra"""
                  try:
                      JNANA_PATH.mkdir(parents=True, exist_ok=True)
                      timestamp = datetime.now().isoformat()
                      filename = JNANA_PATH / f"notion_sync_{timestamp.replace(':', '-')}.json"
                      
                      with open(filename, 'w') as f:
                          json.dump({
                              'timestamp': timestamp,
                              'source': 'notion',
                              'entries': entries,
                              'count': len(entries)
                          }, f, indent=2)
                      
                      logger.info(f"Saved {len(entries)} entries to {filename}")
                      return True
                  except Exception as e:
                      logger.error(f"Failed to save to jnana: {e}")
                      return False
                      
              def sync_knowledge(self):
                  """Main sync function"""
                  logger.info("Starting knowledge synchronization...")
                  
                  # Query Notion
                  entries = self.query_notion_database()
                  
                  # Save to jnana
                  if entries:
                      success = self.save_to_jnana(entries)
                      if success:
                          self.sync_count += 1
                          self.last_sync = datetime.now()
                          
                          # Publish sync event via MQTT
                          if self.mqtt_client:
                              payload = json.dumps({
                                  'event': 'sync_complete',
                                  'timestamp': self.last_sync.isoformat(),
                                  'entries_count': len(entries),
                                  'sync_count': self.sync_count
                              })
                              self.mqtt_client.publish(MQTT_TOPIC, payload)
                  else:
                      logger.info("No entries to sync (or running in stub mode)")
                      
              def sync_loop(self):
                  """Periodic sync loop"""
                  logger.info(f"Starting sync loop with interval: {SYNC_INTERVAL}s")
                  while True:
                      try:
                          self.sync_knowledge()
                      except Exception as e:
                          logger.error(f"Sync error: {e}")
                      time.sleep(SYNC_INTERVAL)
                      
          # Flask API for manual triggers and status
          app = Flask(__name__)
          connector = NotionConnector()
          
          @app.route('/health', methods=['GET'])
          def health():
              return jsonify({
                  'status': 'ok',
                  'service': 'notion-ai-connector',
                  'timestamp': datetime.now().isoformat()
              })
              
          @app.route('/status', methods=['GET'])
          def status():
              return jsonify({
                  'configured': connector.validate_config(),
                  'last_sync': connector.last_sync.isoformat() if connector.last_sync else None,
                  'sync_count': connector.sync_count,
                  'jnana_path': str(JNANA_PATH),
                  'mqtt_broker': MQTT_BROKER,
                  'sync_interval': SYNC_INTERVAL
              })
              
          @app.route('/sync', methods=['POST'])
          def manual_sync():
              try:
                  connector.sync_knowledge()
                  return jsonify({'status': 'success', 'message': 'Sync triggered'})
              except Exception as e:
                  return jsonify({'status': 'error', 'message': str(e)}), 500
                  
          def run_flask():
              app.run(host='0.0.0.0', port=HTTP_PORT)
              
          if __name__ == '__main__':
              logger.info("=== Notion AI Connector Starting ===")
              logger.info(f"Jnana Path: {JNANA_PATH}")
              logger.info(f"MQTT Broker: {MQTT_BROKER}")
              logger.info(f"HTTP Port: {HTTP_PORT}")
              logger.info(f"Sync Interval: {SYNC_INTERVAL}s")
              
              # Setup MQTT
              connector.setup_mqtt()
              
              # Start Flask API in background thread
              flask_thread = Thread(target=run_flask, daemon=True)
              flask_thread.start()
              logger.info(f"API server started on port {HTTP_PORT}")
              
              # Run sync loop in main thread
              connector.sync_loop()
        '';
      };
    };
    
    # Firewall rules for HTTP API
    networking.firewall.allowedTCPPorts = [ config.services.notion-ai-connector.port ];
    
    # Warning about configuration
    warnings = mkIf (config.services.notion-ai-connector.apiKey == "" || 
                     config.services.notion-ai-connector.databaseId == "") [
      ''
        Notion AI Connector is enabled but API credentials are not configured.
        Service will run in stub mode. To enable full functionality:
        1. Obtain API key from https://www.notion.so/my-integrations
        2. Set services.notion-ai-connector.apiKey and databaseId
        3. Ensure the integration has access to your Notion database
      ''
    ];
  };
}
