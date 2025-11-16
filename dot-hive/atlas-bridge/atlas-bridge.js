#!/usr/bin/env node
// Lightweight MQTT -> WebSocket bridge with a small HTTP publish API.
// Usage:
//   npm install ws mqtt express
//   ATLAS_MQTT_BROKER="mqtt://localhost:1883" \
//   ATLAS_PULSE_ENGINE="dojo/pulse/engine" \
//   ATLAS_PULSE_SYNC="dojo/nodes/pulse/#" \
//   ATLAS_WS_PORT=3000 \
//   ATLAS_HTTP_PORT=3001 \
//   node atlas-bridge.js

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const mqtt = require('mqtt');

const MQTT_URL = process.env.ATLAS_MQTT_BROKER || 'mqtt://localhost:1883';
const MQTT_TOPIC = process.env.ATLAS_PULSE_SYNC || 'dojo/nodes/pulse/#';
const WS_PORT = Number(process.env.ATLAS_WS_PORT || 3000);
const HTTP_PORT = Number(process.env.ATLAS_HTTP_PORT || 3001);

console.log(`[atlas-bridge] config: MQTT=${MQTT_URL} topic=${MQTT_TOPIC} WS=${WS_PORT} HTTP=${HTTP_PORT}`);

const app = express();
app.use(express.json());

// health
app.get('/health', (req, res) => res.json({ ok: true, ts: Date.now() }));

// publish endpoint: { topic: "...", payload: {...} }
app.post('/publish', (req, res) => {
  const body = req.body || {};
  if (!body.topic || body.payload === undefined) {
    return res.status(400).json({ error: 'expected { topic, payload }' });
  }
  const payload = typeof body.payload === 'string' ? body.payload : JSON.stringify(body.payload);
  client.publish(body.topic, payload, { qos: 0 }, (err) => {
    if (err) return res.status(500).json({ error: String(err) });
    res.json({ published: true });
  });
});

const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: '/ws' });

wss.on('connection', (ws, req) => {
  ws.send(JSON.stringify({ type: 'connected', now: Date.now() }));
});

server.listen(WS_PORT, () => {
  console.log(`[atlas-bridge] websocket server listening ws://localhost:${WS_PORT}/ws`);
});
app.listen(HTTP_PORT, () => {
  console.log(`[atlas-bridge] http api listening http://localhost:${HTTP_PORT}`);
});

// MQTT client
const client = mqtt.connect(MQTT_URL);
client.on('connect', () => {
  console.log('[atlas-bridge] connected to MQTT broker, subscribing to', MQTT_TOPIC);
  client.subscribe(MQTT_TOPIC, (err) => {
    if (err) console.error('[atlas-bridge] mqtt subscribe error', err);
  });
});
client.on('message', (topic, msgBuf) => {
  const payload = (msgBuf || '').toString();
  const packet = { topic, payload, ts: Date.now() };
  const json = JSON.stringify(packet);
  wss.clients.forEach((c) => {
    if (c.readyState === WebSocket.OPEN) c.send(json);
  });
});
process.on('SIGINT', () => { client.end(true); process.exit(0); });
