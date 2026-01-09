# Observability

This document covers logging and metrics practices for WebPerfMonitor.

## Logs

WebPerfMonitor uses Python's standard `logging` module. The default log level is
`INFO`. Adjust verbosity by setting the `LOG_LEVEL` environment variable and
extending the CLI if needed.

Example:

```bash
LOG_LEVEL=debug PYTHONPATH=src python -m web_perf_monitor.cli run-once
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

