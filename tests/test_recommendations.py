import unittest

from web_perf_monitor.analyzer import Analyzer
from web_perf_monitor.config import Thresholds
from web_perf_monitor.models import Metric
from web_perf_monitor.recommendations import RecommendationEngine


class RecommendationTests(unittest.TestCase):
    def test_generates_recommendations(self):
        analyzer = Analyzer()
        metrics = [
            Metric(url="https://slow.example.com", response_time_seconds=2.0, status_code=200),
            Metric(url="https://slow.example.com", response_time_seconds=1.8, status_code=200),
        ]
        analysis = analyzer.analyze(metrics)
        engine = RecommendationEngine(Thresholds(warning_seconds=0.5, critical_seconds=1.0))
        recommendations = engine.generate(analysis)

        self.assertTrue(recommendations)
        self.assertEqual(recommendations[0].severity, "critical")


if __name__ == "__main__":
    unittest.main()
