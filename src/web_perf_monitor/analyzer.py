from __future__ import annotations

from statistics import mean, median
from typing import Iterable, List

from .models import AnalysisReport, Metric, SiteAnalysis, StatSummary


class Analyzer:
    def analyze(self, metrics: List[Metric]) -> AnalysisReport:
        per_site: List[SiteAnalysis] = []
        total_failures = 0
        by_url: dict[str, List[Metric]] = {}
        for metric in metrics:
            by_url.setdefault(metric.url, []).append(metric)

        for url, entries in by_url.items():
            summary = self._summarize([entry.response_time_seconds for entry in entries])
            failures = sum(1 for entry in entries if not entry.success)
            total_failures += failures
            per_site.append(SiteAnalysis(url=url, summary=summary, failures=failures))

        overall = self._summarize([metric.response_time_seconds for metric in metrics])
        return AnalysisReport(per_site=per_site, overall=overall, total_failures=total_failures)

    def _summarize(self, samples: Iterable[float]) -> StatSummary:
        values = list(samples)
        if not values:
            raise ValueError("No samples provided")
        values.sort()
        return StatSummary(
            min_seconds=values[0],
            max_seconds=values[-1],
            average_seconds=mean(values),
            median_seconds=median(values),
            p95_seconds=self._percentile(values, 0.95),
            sample_size=len(values),
        )

    def _percentile(self, values: List[float], percentile: float) -> float:
        if len(values) == 1:
            return values[0]
        rank = percentile * (len(values) - 1)
        lower_index = int(rank)
        upper_index = min(lower_index + 1, len(values) - 1)
        weight = rank - lower_index
        return values[lower_index] + (values[upper_index] - values[lower_index]) * weight
