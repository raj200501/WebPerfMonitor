# CLI Reference

This document lists all supported commands and options.

## Synopsis

```bash
webperfmonitor [command] [options]
```

The entrypoint for local usage is:

```bash
PYTHONPATH=src python -m web_perf_monitor.cli [command] [options]
```

## Global options

| Option | Description |
| --- | --- |
| `-c`, `--config PATH` | Path to TOML configuration file. |
| `--version` | Print the current version and exit. |
| `-h`, `--help` | Print the help text and exit. |

### Example

```bash
PYTHONPATH=src python -m web_perf_monitor.cli run-once --config config/default.toml
```

## Commands

### `run-once`

Runs a single monitoring cycle and exits. This is the default command when no
command is provided.

```bash
PYTHONPATH=src python -m web_perf_monitor.cli run-once --config config/default.toml
```

Output example:

```
Report written to reports/report-2024-07-09T12-00-00Z.json (1024 bytes)
Webhook: Webhook delivered
```

### `monitor`

Runs monitoring loops continuously using `monitor_interval_seconds` from the
config file.

```bash
PYTHONPATH=src python -m web_perf_monitor.cli monitor --config config/default.toml
```

Use `Ctrl+C` to stop the process.

### `serve`

Starts the report server.

```bash
PYTHONPATH=src python -m web_perf_monitor.cli serve --config config/default.toml
```

If `server.enabled` is false, the CLI exits with a message.

### `validate-config`

Validates the configuration file and exits with a success message.

```bash
PYTHONPATH=src python -m web_perf_monitor.cli validate-config --config config/default.toml
```

### `print-config`

Outputs the parsed configuration (with defaults filled in).

```bash
PYTHONPATH=src python -m web_perf_monitor.cli print-config --config config/default.toml
```

## Environment variables

### `LOG_LEVEL`

Controls log verbosity for the CLI. Supported values include `DEBUG`, `INFO`,
`WARNING`, and `ERROR`.

Example:

```bash
LOG_LEVEL=DEBUG PYTHONPATH=src python -m web_perf_monitor.cli run-once
```

## Exit codes

| Exit code | Meaning |
| --- | --- |
| `0` | Success |
| `1` | CLI error (unknown command, invalid config, or server disabled) |

## Notes

The CLI does not support interactive prompts. All configuration is sourced from
TOML. This ensures deterministic behavior in CI and automated environments.

