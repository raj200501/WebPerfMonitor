# Development Guide

This guide explains how to build, test, and extend WebPerfMonitor.

## Tooling

WebPerfMonitor uses the Crystal language and standard library.

Install or validate Crystal:

```bash
./scripts/bootstrap.sh
```

## Build

```bash
crystal build src/main.cr -o bin/webperfmonitor
```

## Run the CLI

```bash
./tools/crystal run src/main.cr -- run-once --config config/default.yml
```

## Run tests

```bash
./tools/crystal run scripts/spec_runner.cr
```

## Run smoke test

```bash
./tools/crystal run scripts/smoke.cr
```

## Verify all

```bash
./scripts/verify.sh
```

## Project structure

```
config/                # YAML configuration files
scripts/               # Bootstrap + verify scripts
spec/                  # Crystal tests
src/                   # Application code
```

## Adding a new CLI command

1. Update `src/web_perf_monitor/cli.cr` and add a new command name.
2. Implement the command in a helper method or new class.
3. Add tests if the new logic is not already covered by specs.

## Coding style

* Keep modules small and focused.
* Prefer pure functions where possible (e.g., analyzer).
* Capture failures in data structures instead of raising.

## Release checklist

1. Run `./scripts/verify.sh` locally.
2. Ensure README instructions are up to date.
3. Tag release with semantic version.

