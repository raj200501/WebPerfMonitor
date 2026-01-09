# Observability

This document covers logging and metrics practices for WebPerfMonitor.

## Logs

WebPerfMonitor prints operational logs to stdout. You can redirect output or use
systemd/journald for centralized logs.

Example:

```bash
./tools/crystal run src/main.cr -- run-once --config config/default.yml
```

Common log messages:

* Report file write location
* Webhook delivery status
* Server startup banner

## Metrics (self-monitoring)

WebPerfMonitor does not emit its own metrics by default. If you need internal
metrics, consider:

1. Extending the report to include internal durations.
2. Writing a custom wrapper that records runtime and exit codes.
3. Exporting metrics to a Prometheus gateway.

## Health checks

`GET /health` provides a lightweight endpoint for readiness checks when the
report server is enabled.

## Integrating with external systems

Because the report is JSON, many systems can ingest it directly:

* Log pipelines (Filebeat, Fluentd)
* Monitoring dashboards (Grafana Loki, Elastic)
* Incident platforms (PagerDuty, Opsgenie)

## Auditability

Reports are immutable snapshots. Keep them if you need audit trails or
performance history.

