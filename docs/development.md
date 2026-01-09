# Development Guide

This guide explains how to build, test, and extend WebPerfMonitor.

## Tooling

WebPerfMonitor uses Python 3.11+ and the standard library.

Install Python (if needed):

```bash
./scripts/bootstrap.sh
```

## Run the CLI

```bash
PYTHONPATH=src python -m web_perf_monitor.cli run-once --config config/default.toml
```

## Run tests

```bash
PYTHONPATH=src python -m unittest discover -s tests -p "test_*.py"
```

## Run smoke test

```bash
PYTHONPATH=src python scripts/smoke.py
```

## Verify all

```bash
./scripts/verify.sh
```

## Project structure

```
config/                # TOML configuration files
scripts/               # Bootstrap + verify scripts
tests/                 # Unit tests
src/                   # Application code
```

## Adding a new CLI command

1. Update `src/web_perf_monitor/cli.py` and add a new command name.
2. Implement the command in a helper method or new class.
3. Add tests if the new logic is not already covered by unit tests.

## Coding style

* Keep modules small and focused.
* Prefer pure functions where possible (e.g., analyzer).
* Capture failures in data structures instead of raising.

## Release checklist

1. Run `./scripts/verify.sh` locally.
2. Ensure README instructions are up to date.
3. Tag release with semantic version.

