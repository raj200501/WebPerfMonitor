import unittest

from web_perf_monitor.analyzer import Analyzer
from web_perf_monitor.models import Metric


class AnalyzerTests(unittest.TestCase):
    def test_analyzes_metrics(self):
        analyzer = Analyzer()
        metrics = [
            Metric(url="https://example.com", response_time_seconds=0.1, status_code=200),
            Metric(url="https://example.com", response_time_seconds=0.3, status_code=200),
            Metric(url="https://example.com", response_time_seconds=0.2, status_code=500, error="error"),
        ]

        analysis = analyzer.analyze(metrics)

        self.assertEqual(len(analysis.per_site), 1)
        self.assertEqual(analysis.total_failures, 1)
        self.assertEqual(analysis.per_site[0].summary.sample_size, 3)


if __name__ == "__main__":
    unittest.main()
