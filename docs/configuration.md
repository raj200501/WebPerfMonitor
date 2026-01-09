# Configuration Guide

This guide describes all configuration options supported by WebPerfMonitor.
Configuration is loaded from YAML and validated on startup.

## Loading order

1. CLI loads the YAML file specified by `--config`.
2. If no path is provided, it looks for `config/default.yml`.
3. If no file exists, defaults from `Settings` are used.

## Full example

```yaml
websites:
  - "https://example.com"
  - "https://status.example.com"
monitor_interval_seconds: 60
request_timeout_seconds: 5.0
report_output_dir: "reports"
webhook_url: "https://hooks.example.net/webperf"
thresholds:
  warning_seconds: 0.5
  critical_seconds: 1.5
server:
  enabled: true
  host: "127.0.0.1"
  port: 4000
```

## Settings reference

### `websites`

* Type: `Array[String]`
* Required: **yes**
* Behavior: Each URL is probed via HTTP GET.
* Validation: Must include scheme + host (`https://example.com`).

### `monitor_interval_seconds`

* Type: `Int32`
* Required: **yes**
* Default: `60`
* Behavior: Sleep time between monitoring cycles when running in `monitor` mode.

### `request_timeout_seconds`

* Type: `Float64`
* Required: **yes**
* Default: `5.0`
* Behavior: Connection + read timeout for each HTTP request.

### `report_output_dir`

* Type: `String`
* Required: **yes**
* Default: `reports`
* Behavior: Directory that stores JSON reports. Created if missing.

### `webhook_url`

* Type: `String | empty`
* Required: **no**
* Default: empty
* Behavior: When provided, report JSON is POSTed to this URL after each run.

### `thresholds`

* Type: object
* Required: **yes**

#### `thresholds.warning_seconds`

* Type: `Float64`
* Default: `0.5`
* Behavior: If a site's max response time exceeds this value, a warning
  recommendation is added to the report.

#### `thresholds.critical_seconds`

* Type: `Float64`
* Default: `1.5`
* Behavior: If a site's max response time exceeds this value, a critical
  recommendation is added to the report.

### `server`

* Type: object
* Required: **yes**

#### `server.enabled`

* Type: `Bool`
* Default: `false`
* Behavior: CLI `serve` command exits with a helpful message unless enabled.

#### `server.host`

* Type: `String`
* Default: `127.0.0.1`
* Behavior: Host interface for the report server.

#### `server.port`

* Type: `Int32`
* Default: `4000`
* Behavior: Port for the report server. Must be 1-65535.

## Validation errors

If configuration is invalid, WebPerfMonitor exits immediately with
`ConfigError`. Common cases:

* Empty `websites` list
* URLs missing a scheme or host
* Non-positive timeouts
* Warning threshold larger than critical threshold
* Server port out of range

## Tips for local development

* Use `config/sample.yml` for localhost testing.
* Point `webhook_url` to a local receiver (see `scripts/smoke.cr`).
* Set `monitor_interval_seconds` low for quick feedback.

