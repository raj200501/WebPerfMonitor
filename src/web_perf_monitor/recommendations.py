from __future__ import annotations

from typing import List

from .config import Thresholds
from .models import AnalysisReport, Recommendation


class RecommendationEngine:
    def __init__(self, thresholds: Thresholds) -> None:
        self._thresholds = thresholds

    def generate(self, analysis: AnalysisReport) -> List[Recommendation]:
        recommendations: List[Recommendation] = []
        for site in analysis.per_site:
            max_seconds = site.summary.max_seconds
            if max_seconds >= self._thresholds.critical_seconds:
                recommendations.append(
                    Recommendation(
                        url=site.url,
                        severity="critical",
                        message=(
                            f"Response time exceeded {self._thresholds.critical_seconds}s. "
                            "Investigate backend latency or caching."
                        ),
                    )
                )
            elif max_seconds >= self._thresholds.warning_seconds:
                recommendations.append(
                    Recommendation(
                        url=site.url,
                        severity="warning",
                        message=(
                            f"Response time exceeded {self._thresholds.warning_seconds}s. "
                            "Consider optimizing assets or network paths."
                        ),
                    )
                )

            if site.failures > 0:
                recommendations.append(
                    Recommendation(
                        url=site.url,
                        severity="warning",
                        message=f"Observed {site.failures} failed checks. Review uptime or error rates.",
                    )
                )

        return recommendations
