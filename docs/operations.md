# Operations Guide

This document covers running WebPerfMonitor in common environments.

## Running in batch mode

Batch mode executes a single monitoring cycle and exits. This is useful for
cron jobs or ad-hoc checks.

```bash
./scripts/run.sh
```

The command loads `config/default.yml` and writes a JSON report to `reports/`.

## Running continuously

Continuous mode runs a monitoring cycle every `monitor_interval_seconds`.

```bash
./tools/crystal run src/main.cr -- monitor --config config/default.yml
```

You can stop the process with `Ctrl+C`.

## Running the report server

The server exposes health checks and the latest report. Enable it in config and
run:

```bash
./tools/crystal run src/main.cr -- serve --config config/default.yml
```

Endpoints:

* `GET /health` -> `ok`
* `GET /latest` -> JSON report or 404 if no reports

## Log output

Logging uses standard output for now. If you need structured logs, wrap the
process and redirect output to a log file.

## Report storage and rotation

Reports are written to the output directory with timestamps. You may want to
implement retention policies (e.g., keep last 100 files). For now, you can rely
on external log rotation or cron-based cleanup.

## Webhook integration

Set `webhook_url` to a receiver that accepts JSON POST requests. The webhook
receives the full report payload, so ensure the endpoint can handle the size of
your monitoring data.

## Security considerations

* Avoid pointing the monitor at endpoints that require authentication unless you
  are confident the network path is secure.
* If you need authentication, implement a proxy that injects headers and keep
  this tool on a trusted network.
* The report server is intended for local usage. It does not implement
  authentication or TLS.

