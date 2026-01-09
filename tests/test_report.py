import json
import unittest

from web_perf_monitor.analyzer import Analyzer
from web_perf_monitor.models import Metric
from web_perf_monitor.recommendations import RecommendationEngine
from web_perf_monitor.report import ReportBuilder
from web_perf_monitor.config import Thresholds


class ReportTests(unittest.TestCase):
    def test_generates_report_json(self):
        report = ReportBuilder()
        metrics = [Metric(url="https://example.com", response_time_seconds=0.2, status_code=200)]
        analysis = Analyzer().analyze(metrics)
        recommendations = RecommendationEngine(Thresholds()).generate(analysis)

        report_data = report.generate(metrics, analysis, recommendations)
        payload = json.loads(report.to_json(report_data))

        self.assertIn("timestamp", payload)
        self.assertIn("metrics", payload)


if __name__ == "__main__":
    unittest.main()
