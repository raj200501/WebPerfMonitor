# Architecture

This document explains how WebPerfMonitor is structured internally and how data
flows through the system. It is written for maintainers who need to extend the
project or debug production behavior.

## High-level flow

1. **Configuration is loaded** from YAML (or defaults if no file is present).
2. **Monitor** collects response-time metrics from the configured target URLs.
3. **Analyzer** builds statistics across the collected metrics.
4. **Recommendation engine** turns analysis results into actionable guidance.
5. **Report generator** creates a JSON report.
6. **Storage** writes the report to disk for later inspection.
7. **Integration** (optional) sends the report to a webhook.
8. **Server** (optional) can serve the latest report over HTTP.

```
+-------------+      +-----------+      +-----------+
| Config YAML | ---> | Monitor   | ---> | Analyzer  |
+-------------+      +-----------+      +-----------+
                               |               |
                               v               v
                          +-----------+   +-----------------+
                          | Report    |   | Recommendations |
                          +-----------+   +-----------------+
                                   |              |
                                   v              v
                             +-----------+   +-----------+
                             | Storage   |   | Webhook   |
                             +-----------+   +-----------+
                                   |
                                   v
                             +-----------+
                             | Server    |
                             +-----------+
```

## Modules

### Configuration

* `WebPerfMonitor::Settings` (`src/web_perf_monitor/config.cr`) maps YAML into
  strongly validated settings.
* `WebPerfMonitor::Config` loads and validates settings from a given path.

### Monitor

* `WebPerfMonitor::Monitor` (`src/web_perf_monitor/monitor.cr`) makes HTTP GET
  requests to each configured URL.
* Each request yields a `Metric` containing:
  * URL
  * Response time (seconds)
  * Status code (if available)
  * Error message (if any)

The monitor never raises on request errors; it instead records the failure into
`Metric.error`. This is critical to ensure one bad endpoint does not break a full
monitoring cycle.

### Metrics & Analysis

* `WebPerfMonitor::Metric` describes each observation.
* `WebPerfMonitor::Analyzer` computes statistics and failure counts.
* `StatSummary` provides:
  * min
  * max
  * average
  * median
  * p95
  * sample size

Percentile calculations use a deterministic linear interpolation method on the
sorted list of samples. This avoids external dependencies while remaining
stable across runs.

### Recommendations

* `WebPerfMonitor::RecommendationEngine` compares
  `StatSummary.max_seconds` against configured thresholds.
* Recommendations are emitted on:
  * Warning threshold exceedance
  * Critical threshold exceedance
  * Any recorded failures

Recommendation output is stored in the report for downstream automation.

### Report

`WebPerfMonitor::Report` builds a `ReportData` object and serializes it to JSON.
The report format is stable and designed for ingestion by analytics pipelines.

### Storage

`WebPerfMonitor::FileStore` persists JSON reports under the configured output
path. The filename is derived from the report timestamp and normalized to avoid
invalid characters (colons are replaced with dashes).

### Integration

`WebhookClient` posts the report JSON to a configured URL. It is intentionally
simple to keep the project dependency-free.

### Server

`ReportServer` is an optional HTTP server that exposes:

* `GET /health` — simple health check string.
* `GET /latest` — returns the most recent JSON report if present.

It is only started if `server.enabled` is set in the configuration and the CLI
invokes the `serve` command.

## Error handling strategy

* Configuration errors raise `ConfigError` and stop execution.
* Monitoring errors are captured as `Metric.error` entries.
* Webhook failures are returned in `WebhookResult` objects.
* CLI always exits non-zero on invalid command or invalid config.

## Extensibility

To add new analysis:

1. Add fields to `AnalysisReport` or define a new summary structure.
2. Extend `Analyzer.analyze` to compute the new fields.
3. Add corresponding specs under `spec/`.
4. Update documentation to mention the new metric.

To add new integrations:

1. Create a new integration class in `src/web_perf_monitor`.
2. Add config entries to `Settings`.
3. Update `Runner#send_webhook` to branch to the new integration.
4. Add a new spec that uses a local HTTP server.

## File map

* `src/web_perf_monitor/cli.cr` — command-line interface
* `src/web_perf_monitor/config.cr` — config loading + validation
* `src/web_perf_monitor/monitor.cr` — HTTP probes
* `src/web_perf_monitor/analyzer.cr` — stats + summaries
* `src/web_perf_monitor/recommendations.cr` — alerting logic
* `src/web_perf_monitor/report.cr` — report formatting
* `src/web_perf_monitor/storage.cr` — report persistence
* `src/web_perf_monitor/integration.cr` — webhook integration
* `src/web_perf_monitor/server.cr` — HTTP server for latest report
* `src/web_perf_monitor/runner.cr` — orchestration layer

## Design decisions

### Why YAML?

YAML is easy for operators to read and is supported by Crystal's standard
library. This keeps the project dependency-free.

### Why a file-based report store?

Many teams want a report artifact for audit or debugging. File storage is
portable, deterministic, and works in both local and CI environments.

### Why not multithreading?

The monitor currently checks URLs sequentially to keep the results deterministic.
Parallelism can be added later, but would require additional synchronization for
timing-sensitive tests.

### Why HTTP server optional?

Some environments prefer to run the tool in batch mode (e.g., cron). Others want
an always-on service. Making the server optional keeps the CLI flexible.

## Testing notes

The specs under `spec/` use local HTTP servers to avoid network dependencies.
This ensures reproducible behavior in CI. The smoke test in `scripts/smoke.cr`
starts a local target server and a local webhook, runs a single monitoring cycle,
and validates that:

* The report file is written
* The metrics include the expected URL
* The webhook was delivered

This is the canonical end-to-end check used by CI.

## Future roadmap (ideas)

* Add parallel collection with configurable concurrency limits.
* Support Prometheus export for metrics.
* Add HTML report rendering.
* Add retention policies for report files.

