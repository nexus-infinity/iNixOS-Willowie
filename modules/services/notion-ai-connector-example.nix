# Example configuration for Notion AI Connector
# Copy and customize this file to enable Notion integration

{ config, pkgs, lib, ... }:

{
  # Enable the Notion AI Connector service
  services.notion-ai-connector = {
    enable = true;
    
    # REQUIRED: Your Notion integration API key
    # Get from: https://www.notion.so/my-integrations
    # IMPORTANT: For production, use secrets management instead of hardcoding
    apiKey = "secret_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    
    # REQUIRED: Your Notion database ID
    # This is the UUID from your database URL:
    # https://www.notion.so/yourworkspace/DATABASE_ID?v=...
    databaseId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    
    # OPTIONAL: Sync interval in seconds (default: 300 = 5 minutes)
    syncInterval = 300;
    
    # OPTIONAL: Local path for jnana chakra knowledge storage
    jnanaPath = "/jnana/akasha/eternal_records";
    
    # OPTIONAL: MQTT broker for real-time sync events
    mqttBroker = "mqtt://localhost:1883";
    
    # OPTIONAL: MQTT topic for sync events
    mqttTopic = "jnana/notion/sync";
    
    # OPTIONAL: HTTP API port for manual triggers
    port = 8084;
    
    # OPTIONAL: Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    logLevel = "INFO";
  };
}

# Usage Instructions:
# 
# 1. Create a Notion Integration:
#    - Go to https://www.notion.so/my-integrations
#    - Click "New integration"
#    - Name it (e.g., "iNixOS Willowie Connector")
#    - Select the workspace
#    - Copy the "Internal Integration Token"
#
# 2. Share your database with the integration:
#    - Open your Notion database
#    - Click "..." menu → "Add connections"
#    - Select your integration
#
# 3. Get your database ID:
#    - Open your database in Notion
#    - Copy the URL: https://notion.so/workspace/DATABASE_ID?v=...
#    - The DATABASE_ID is a 32-character hex string
#
# 4. Configure the service:
#    - Copy this file to your configuration
#    - Update apiKey and databaseId
#    - Consider using agenix or sops-nix for secrets management
#
# 5. Rebuild your system:
#    sudo nixos-rebuild switch --flake .#BearsiMac
#
# 6. Test the service:
#    - Check status: curl http://localhost:8084/status
#    - Trigger manual sync: curl -X POST http://localhost:8084/sync
#    - View logs: journalctl -u notion-ai-connector -f
#
# API Endpoints:
# - GET  /health - Health check
# - GET  /status - Sync status and configuration
# - POST /sync   - Trigger manual synchronization
#
# MQTT Topics:
# - jnana/notion/sync - Sync status events (published)
# - jnana/notion/sync/trigger - Trigger sync (subscribe)
