# Integrations Guide

WebPerfMonitor ships with a simple webhook integration. This document explains
how to use it and how to extend it.

## Webhook integration

To enable webhook delivery, set `webhook_url` in your config:

```toml
webhook_url = "https://hooks.example.net/webperf"
```

The webhook receives the full JSON report as the POST body with
`Content-Type: application/json`.

### Expected responses

The webhook is considered successful if it returns a 2xx status code. Any other
status is considered a failure and recorded in `WebhookResult`.

### Example receiver

You can test with a local receiver by running the smoke test:

```bash
PYTHONPATH=src python scripts/smoke.py
```

This script spins up a local HTTP server that accepts POST requests.

## Custom integrations

If you want to push reports to another system, you can build your own
integration class. Suggested approach:

1. Add a new integration class under `src/web_perf_monitor`.
2. Add a config option to `Settings`.
3. Update `Runner._send_webhook` (or create a more general `send_integrations`)
   to route to the new integration.
4. Add a new test that uses a local server.

## Example: adding a Slack webhook

Pseudo steps:

1. Add `slack_webhook_url` to config.
2. Create `SlackWebhookClient` class.
3. Format a message payload using the report data.
4. Post to Slack.

## Testing integrations

Use local HTTP servers in tests to avoid hitting external APIs.

