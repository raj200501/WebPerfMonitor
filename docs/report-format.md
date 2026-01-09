# Report Format

This document describes the JSON schema emitted by WebPerfMonitor.

## Top-level object

| Field | Type | Description |
| --- | --- | --- |
| `timestamp` | `String` | UTC timestamp when the report was generated. |
| `metrics` | `Array<Metric>` | Raw metrics collected from each target. |
| `analysis` | `AnalysisReport` | Aggregated statistics. |
| `recommendations` | `Array<Recommendation>` | Optimization guidance. |

## Metric

```json
{
  "url": "https://example.com",
  "response_time_seconds": 0.123,
  "status_code": 200,
  "error": null
}
```

* `url`: Target URL.
* `response_time_seconds`: Total request duration.
* `status_code`: HTTP status (null if request failed).
* `error`: Error string (null if success).

## AnalysisReport

```json
{
  "per_site": [
    {
      "url": "https://example.com",
      "summary": {
        "min_seconds": 0.1,
        "max_seconds": 0.2,
        "average_seconds": 0.15,
        "median_seconds": 0.15,
        "p95_seconds": 0.2,
        "sample_size": 2
      },
      "failures": 0
    }
  ],
  "overall": {
    "min_seconds": 0.1,
    "max_seconds": 0.2,
    "average_seconds": 0.15,
    "median_seconds": 0.15,
    "p95_seconds": 0.2,
    "sample_size": 2
  },
  "total_failures": 0
}
```

### StatSummary

* `min_seconds`: Fastest response time.
* `max_seconds`: Slowest response time.
* `average_seconds`: Mean response time.
* `median_seconds`: Median response time.
* `p95_seconds`: 95th percentile response time.
* `sample_size`: Number of samples used.

## Recommendation

```json
{
  "url": "https://example.com",
  "severity": "warning",
  "message": "Response time exceeded 0.5s. Consider optimizing assets or network paths."
}
```

* `severity` is `warning` or `critical`.
* `message` is human-readable guidance.

## Timestamp format

The timestamp is emitted in ISO 8601 format with timezone offset, for example:

```
2024-07-09T12:00:00+00:00
```

## Notes

* The report is deterministic based on the collected metrics.
* Use this format to build integrations with dashboards or alerting tools.

