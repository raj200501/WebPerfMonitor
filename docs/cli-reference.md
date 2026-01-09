# CLI Reference

This document lists all supported commands and options.

## Synopsis

```bash
webperfmonitor [command] [options]
```

The entrypoint for local usage is:

```bash
./tools/crystal run src/main.cr -- [command] [options]
```

## Global options

| Option | Description |
| --- | --- |
| `-c`, `--config PATH` | Path to YAML configuration file. |
| `--version` | Print the current version and exit. |
| `-h`, `--help` | Print the help text and exit. |

### Example

```bash
./tools/crystal run src/main.cr -- run-once --config config/default.yml
```

## Commands

### `run-once`

Runs a single monitoring cycle and exits. This is the default command when no
command is provided.

```bash
./tools/crystal run src/main.cr -- run-once --config config/default.yml
```

Output example:

```
Report written to reports/report-2024-07-09T12-00-00+00-00.json (1024 bytes)
Webhook: Webhook delivered
```

### `monitor`

Runs monitoring loops continuously using `monitor_interval_seconds` from the
config file.

```bash
./tools/crystal run src/main.cr -- monitor --config config/default.yml
```

Use `Ctrl+C` to stop the process.

### `serve`

Starts the report server.

```bash
./tools/crystal run src/main.cr -- serve --config config/default.yml
```

If `server.enabled` is false, the CLI exits with a message.

### `validate-config`

Validates the configuration file and exits with a success message.

```bash
./tools/crystal run src/main.cr -- validate-config --config config/default.yml
```

### `print-config`

Outputs the parsed configuration (with defaults filled in).

```bash
./tools/crystal run src/main.cr -- print-config --config config/default.yml
```

## Exit codes

| Exit code | Meaning |
| --- | --- |
| `0` | Success |
| `1` | CLI error (unknown command, invalid config, or server disabled) |

## Notes

The CLI does not support interactive prompts. All configuration is sourced from
YAML. This ensures deterministic behavior in CI and automated environments.
