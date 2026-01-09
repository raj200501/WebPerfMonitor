# Runbook

This runbook provides operational procedures for WebPerfMonitor.

## Daily operations

### Check latest report

```bash
ls -lt reports | head -n 5
```

### View report content

```bash
cat reports/report-<timestamp>.json
```

### Verify webhook delivery

Review the CLI output. Successful deliveries print:

```
Webhook: Webhook delivered
```

## Incident response

### Reports not updating

1. Confirm the process is running:
   ```bash
   ps aux | grep webperfmonitor
   ```
2. Check for exceptions in the logs.
3. Validate that target URLs are accessible.

### Report server not responding

1. Ensure `server.enabled` is true in config.
2. Confirm the port is not in use:
   ```bash
   lsof -i :4000
   ```
3. Restart the server command:
   ```bash
   ./tools/crystal run src/main.cr -- serve --config config/default.yml
   ```

### Webhook latency

If webhook delivery is slow, consider:

* Moving the webhook receiver closer to the monitor host.
* Implementing an asynchronous queue (future enhancement).
* Checking the receiver for rate limits.

## Maintenance

### Clean up old reports

Example cleanup (keep last 100):

```bash
ls -t reports/report-*.json | tail -n +101 | xargs rm -f
```

### Rotate logs

If you run under systemd, use `journald` for rotation. For custom runs, consider
redirecting output to a log file and using `logrotate`.

## Environment hardening

* Run as a dedicated user with minimal permissions.
* Restrict outbound network access to only the monitored URLs and webhook.
* Use a firewall to limit server exposure.

## Upgrades

1. Pull the latest code.
2. Run `./scripts/verify.sh` to ensure local health.
3. Restart your monitoring process.

## Backup

If reports are critical, back up the `reports/` directory regularly. This can be
as simple as a nightly `tar` or a sync to object storage.

