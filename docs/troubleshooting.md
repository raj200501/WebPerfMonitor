# Troubleshooting

This guide lists common issues and how to resolve them.

## "command not found: crystal"

**Cause**: Crystal is not installed on the system.

**Fix**:

```bash
./scripts/bootstrap.sh
```

If Crystal is not available, the project uses the local shim in `tools/crystal`.

## "ConfigError: Invalid website URL"

**Cause**: URLs in the config are missing a scheme or host.

**Fix**: Ensure URLs are fully qualified:

```yaml
websites:
  - "https://example.com"
```

## "Server disabled in config"

**Cause**: `server.enabled` is `false` but `serve` command was used.

**Fix**:

```yaml
server:
  enabled: true
  host: "127.0.0.1"
  port: 4000
```

Then rerun:

```bash
./tools/crystal run src/main.cr -- serve --config config/default.yml
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

**Cause**: CI requires Crystal.

**Fix**:

* The workflow uses a Crystal container to run `./scripts/verify.sh`. Ensure the
  container image is available.

## High response times

**Cause**: Target site is slow or throttling.

**Fix**:

* Increase `request_timeout_seconds`.
* Inspect the report and focus on the slowest endpoints.
* Check availability with `curl -w "%{time_total}"`.

