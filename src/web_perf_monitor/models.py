from __future__ import annotations

from dataclasses import dataclass
from typing import List, Optional


@dataclass
class Metric:
    url: str
    response_time_seconds: float
    status_code: Optional[int] = None
    error: Optional[str] = None

    @property
    def success(self) -> bool:
        if self.error is not None:
            return False
        if self.status_code is None:
            return False
        return self.status_code < 500


@dataclass
class StatSummary:
    min_seconds: float
    max_seconds: float
    average_seconds: float
    median_seconds: float
    p95_seconds: float
    sample_size: int


@dataclass
class SiteAnalysis:
    url: str
    summary: StatSummary
    failures: int


@dataclass
class AnalysisReport:
    per_site: List[SiteAnalysis]
    overall: StatSummary
    total_failures: int


@dataclass
class Recommendation:
    url: str
    severity: str
    message: str


@dataclass
class ReportData:
    timestamp: str
    metrics: List[Metric]
    analysis: AnalysisReport
    recommendations: List[Recommendation]


@dataclass
class ReportOutput:
    path: str
    bytes_written: int


@dataclass
class WebhookResult:
    success: bool
    status_code: Optional[int]
    message: str
