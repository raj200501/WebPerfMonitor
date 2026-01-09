# Metrics Reference

This guide explains how WebPerfMonitor records and interprets metrics.

## Response time

Response time is the total wall-clock duration between sending the HTTP request
and receiving the full response. It includes network latency and server
processing time.

Measurement details:

* Uses `Time.monotonic` for timing accuracy.
* Includes DNS, connect, and response body read time.
* If a request errors, the response time is still recorded up to the failure.

## Status codes

If the request succeeds, `status_code` is recorded from the HTTP response. When
requests fail (timeout, DNS error, etc.) the status code is null and the error
string contains details.

## Failures

Failures are any metric where:

* `error` is present
* or `status_code` is 500+ (server error)

These failures are tracked in `SiteAnalysis.failures` and
`AnalysisReport.total_failures`.

## Percentiles

Percentiles are computed from the sorted list of response times using linear
interpolation. For `p95`:

1. Compute the rank `0.95 * (n - 1)`.
2. Interpolate between the lower and upper sample values.

This method provides stable results for small sample sizes.

## Recommendations

Recommendations are generated based on the configured thresholds:

* **Warning** when max response time exceeds `warning_seconds`.
* **Critical** when max response time exceeds `critical_seconds`.

Each recommendation is tied to a specific URL.

