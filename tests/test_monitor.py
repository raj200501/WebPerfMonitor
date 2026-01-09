import unittest

from web_perf_monitor.config import Settings, Thresholds, ServerSettings
from web_perf_monitor.monitor import Monitor

from tests.helpers import SimpleHandler, available_port, start_server, stop_server


class MonitorTests(unittest.TestCase):
    def test_collects_metrics(self):
        port = available_port()
        server = start_server(SimpleHandler, port)
        settings = Settings(
            websites=[f"http://127.0.0.1:{port}"],
            monitor_interval_seconds=1,
            request_timeout_seconds=2.0,
            report_output_dir="tmp/monitor",
            webhook_url=None,
            thresholds=Thresholds(),
            server=ServerSettings(),
        )

        monitor = Monitor(settings)
        metrics = monitor.collect_metrics()

        self.assertEqual(len(metrics), 1)
        self.assertEqual(metrics[0].status_code, 200)
        stop_server(server)


if __name__ == "__main__":
    unittest.main()
