import os
import tempfile
import unittest

from web_perf_monitor.config import Config, ConfigError, Settings, Thresholds, ServerSettings


class ConfigTests(unittest.TestCase):
    def test_loads_default_when_missing(self):
        config = Config.load("tmp/missing.toml")
        self.assertTrue(config.settings.websites)

    def test_validates_invalid_settings(self):
        settings = Settings(
            websites=[],
            monitor_interval_seconds=0,
            request_timeout_seconds=0.0,
            report_output_dir="",
            webhook_url=None,
            thresholds=Thresholds(),
            server=ServerSettings(),
        )
        with self.assertRaises(ConfigError):
            settings.validate()

    def test_loads_from_toml(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "config.toml")
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(
                    "websites = [\"https://example.com\"]\n"
                    "monitor_interval_seconds = 10\n"
                    "request_timeout_seconds = 3.0\n"
                    "report_output_dir = \"tmp/output\"\n"
                    "\n"
                    "[thresholds]\n"
                    "warning_seconds = 0.4\n"
                    "critical_seconds = 0.9\n"
                    "\n"
                    "[server]\n"
                    "enabled = true\n"
                    "host = \"127.0.0.1\"\n"
                    "port = 5050\n"
                )
            config = Config.load(path)
            self.assertEqual(config.settings.monitor_interval_seconds, 10)
            self.assertEqual(config.settings.thresholds.critical_seconds, 0.9)
            self.assertEqual(config.settings.server.port, 5050)


if __name__ == "__main__":
    unittest.main()
