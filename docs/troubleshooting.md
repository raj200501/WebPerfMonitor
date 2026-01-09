# Troubleshooting

This guide lists common issues and how to resolve them.

## "command not found: python"

**Cause**: Python is not installed on the system.

**Fix**:

```bash
./scripts/bootstrap.sh
```

The bootstrap script validates your Python version.

## "ConfigError: Invalid website URL"

**Cause**: URLs in the config are missing a scheme or host.

**Fix**: Ensure URLs are fully qualified:

```toml
websites = ["https://example.com"]
```

## "Server disabled in config"

**Cause**: `server.enabled` is `false` but `serve` command was used.

**Fix**:

```toml
[server]
enabled = true
host = "127.0.0.1"
port = 4000
```

Then rerun:

```bash
PYTHONPATH=src python -m web_perf_monitor.cli serve --config config/default.toml
```

## Reports are not written

**Cause**: The output directory is not writable.

**Fix**:

1. Verify permissions on `report_output_dir`.
2. Choose a different output directory in the config.

## Webhook failures

**Symptom**: Report shows `Webhook failed` message.

**Root causes**:

* Endpoint is not reachable
* TLS errors
* Non-2xx response

**Fixes**:

* Confirm the URL is accessible (`curl -v <url>`).
* If self-signed TLS, proxy through a local service.
* Ensure the receiver responds with a 2xx status code.

## Test failures in CI

**Cause**: CI requires Python 3.11+.

**Fix**:

* The workflow runs `scripts/bootstrap.sh` automatically. If that fails, ensure
  your CI image has Python 3.11 or later.

## High response times

**Cause**: Target site is slow or throttling.

**Fix**:

* Increase `request_timeout_seconds`.
* Inspect the report and focus on the slowest endpoints.
* Check availability with `curl -w "%{time_total}"`.

