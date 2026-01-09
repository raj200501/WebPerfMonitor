# Testing Guide

WebPerfMonitor relies on deterministic unit tests and a smoke test to validate
end-to-end behavior.

## Test layers

1. **Unit tests** (`tests/`) validate each module in isolation.
2. **Smoke test** (`scripts/smoke.py`) spins up local HTTP servers and runs a
   full monitoring cycle.

## Running tests locally

```bash
PYTHONPATH=src python -m unittest discover -s tests -p "test_*.py"
```

## Running the smoke test

```bash
PYTHONPATH=src python scripts/smoke.py
```

## Full verification

```bash
./scripts/verify.sh
```

## Writing new tests

### Example: Testing a new analyzer metric

1. Create a new test file under `tests/`.
2. Build a list of `Metric` objects with known response times.
3. Assert the computed statistics.

### Example: Testing a new integration

1. Spin up a local `HTTPServer` in the test.
2. Configure the integration to use `http://127.0.0.1:<port>`.
3. Assert that the integration returns success.

## Notes on determinism

Tests should avoid external network calls. Always use local servers or mocked
responses. This keeps CI reliable and fast.

