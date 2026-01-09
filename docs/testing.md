# Testing Guide

WebPerfMonitor relies on deterministic specs and a smoke test to validate
end-to-end behavior.

## Test layers

1. **Specs** (`spec/`) validate each module in isolation.
2. **Smoke test** (`scripts/smoke.cr`) spins up local HTTP servers and runs a
   full monitoring cycle.

## Running specs locally

```bash
./tools/crystal run scripts/spec_runner.cr
```

## Running the smoke test

```bash
./tools/crystal run scripts/smoke.cr
```

## Full verification

```bash
./scripts/verify.sh
```

## Writing new tests

### Example: Testing a new analyzer metric

1. Create a new spec in `spec/`.
2. Build a list of `Metric` objects with known response times.
3. Assert the computed statistics.

### Example: Testing a new integration

1. Spin up a local HTTP server in the spec.
2. Configure the integration to use `http://127.0.0.1:<port>`.
3. Assert that the integration returns success.

## Notes on determinism

Tests should avoid external network calls. Always use local servers or mocked
responses. This keeps CI reliable and fast.

