# FAQ

## Why Python?

Python provides a mature standard library, quick iteration, and straightforward
HTTP primitives, making it a good fit for a lightweight monitoring tool.

## Does WebPerfMonitor support HTTPS?

Yes. The monitor uses Python's standard HTTP client, which supports HTTPS.
Ensure that your runtime has access to the system's CA certificates.

## Can I monitor multiple endpoints?

Yes. Add multiple entries to the `websites` list in your configuration. The
monitor will check each URL sequentially.

## Why are requests sequential?

Sequential requests keep test results deterministic and avoid amplifying load on
target services. Concurrency can be added later if needed.

## What is the difference between `run-once` and `monitor`?

* `run-once` performs a single cycle and exits.
* `monitor` repeats the cycle based on `monitor_interval_seconds`.

## How do I reduce report size?

Reports include all metrics collected in the run. To reduce size, monitor fewer
URLs or reduce the number of collection cycles.

## Can I change the report format?

Yes. Update `ReportData` in `src/web_perf_monitor/report.py`. Ensure the changes
are reflected in `docs/report-format.md` and update tests accordingly.

## Where are reports stored?

Reports are stored under `report_output_dir` (default: `reports`). Each file is
named using the UTC timestamp from the report.

## What happens if a site is down?

The monitor records the failure in the metric's `error` field and continues. The
analysis includes a failure count per site.

## Can I use authentication headers?

Not currently. This tool intentionally keeps the HTTP client minimal. For
authenticated endpoints, consider using a proxy that injects headers.

## How do I run the report server?

Enable `server.enabled` in the config and run:

```bash
PYTHONPATH=src python -m web_perf_monitor.cli serve --config config/default.toml
```

## Why is the report server HTTP-only?

The server is intended for local usage and internal networks. If you need TLS,
run it behind a reverse proxy.

## Does CI run integration tests?

Yes. CI runs `./scripts/verify.sh`, which executes unit tests and a smoke test
that starts local HTTP servers.

## How do I add a new test target?

Edit `config/default.toml` and add a new URL to `websites`. You can also keep
separate config files per environment.

