from __future__ import annotations

import json
from dataclasses import asdict
from datetime import datetime, timezone
from typing import List

from .models import AnalysisReport, Metric, Recommendation, ReportData


class ReportBuilder:
    def generate(self, metrics: List[Metric], analysis: AnalysisReport, recommendations: List[Recommendation]) -> ReportData:
        timestamp = datetime.now(timezone.utc).isoformat()
        return ReportData(timestamp=timestamp, metrics=metrics, analysis=analysis, recommendations=recommendations)

    def to_json(self, report: ReportData, pretty: bool = True) -> str:
        payload = asdict(report)
        if pretty:
            return json.dumps(payload, indent=2, sort_keys=True)
        return json.dumps(payload)
