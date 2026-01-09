import os
import unittest

from web_perf_monitor.config import Settings, Thresholds, ServerSettings
from web_perf_monitor.runner import Runner

from tests.helpers import SimpleHandler, available_port, start_server, stop_server


class RunnerTests(unittest.TestCase):
    def test_run_once(self):
        port = available_port()
        server = start_server(SimpleHandler, port)

        settings = Settings(
            websites=[f"http://127.0.0.1:{port}"],
            monitor_interval_seconds=1,
            request_timeout_seconds=2.0,
            report_output_dir="tmp/runner",
            webhook_url=None,
            thresholds=Thresholds(),
            server=ServerSettings(),
        )

        runner = Runner(settings)
        result = runner.run_once()

        self.assertTrue(os.path.exists(result.output.path))
        stop_server(server)


if __name__ == "__main__":
    unittest.main()
