# WebPerfMonitor

WebPerfMonitor is a Crystal-based web performance monitoring tool. It collects
response-time metrics for a list of URLs, analyzes performance, generates JSON
reports, and optionally forwards those reports to a webhook. It can also serve
the latest report over HTTP for quick inspection.

## Features

- Collects web performance metrics via HTTP probes
- Computes response-time statistics (min/max/avg/median/p95)
- Generates JSON reports with recommendations
- Optional webhook delivery
- Optional HTTP server for the latest report

## Requirements

- Crystal 1.6+ (or use the local shim in `tools/crystal`)

## Installation

Clone the repository and verify Crystal is available:

```bash
git clone https://github.com/your-username/WebPerfMonitor.git
cd WebPerfMonitor
./scripts/bootstrap.sh
```

## Configuration

Configuration is stored in YAML. Start from `config/default.yml`:

```yaml
websites:
  - "https://example.com"
monitor_interval_seconds: 60
request_timeout_seconds: 5.0
report_output_dir: "reports"
webhook_url: ""
thresholds:
  warning_seconds: 0.5
  critical_seconds: 1.5
server:
  enabled: false
  host: "127.0.0.1"
  port: 4000
```

See [`docs/configuration.md`](docs/configuration.md) for details.

## Usage

### Run a single monitoring cycle

```bash
./scripts/run.sh
```

This writes a JSON report to `reports/` and prints the report path.

### Run continuously

```bash
./tools/crystal run src/main.cr -- monitor --config config/default.yml
```

### Serve the latest report

Enable the server in your config and run:

```bash
./tools/crystal run src/main.cr -- serve --config config/default.yml
```

Endpoints:

- `GET /health` -> `ok`
- `GET /latest` -> JSON report

## Verification

Run the full verification suite (unit tests + smoke test):

```bash
./scripts/verify.sh
```

## Verified Quickstart

The following commands were executed successfully:

```bash
./scripts/bootstrap.sh
./scripts/run.sh
```

## Verified Verification

The following command was executed successfully:

```bash
./scripts/verify.sh
```

## Troubleshooting

See [`docs/troubleshooting.md`](docs/troubleshooting.md).

## Additional documentation

- [`docs/architecture.md`](docs/architecture.md)
- [`docs/configuration.md`](docs/configuration.md)
- [`docs/operations.md`](docs/operations.md)
- [`docs/report-format.md`](docs/report-format.md)
- [`docs/metrics.md`](docs/metrics.md)
- [`docs/development.md`](docs/development.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.
