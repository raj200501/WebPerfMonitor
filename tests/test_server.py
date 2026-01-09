import json
import os
import tempfile
import time
import unittest
import urllib.request

from web_perf_monitor.server import ReportServer
from web_perf_monitor.storage import FileStore

from tests.helpers import available_port


class ServerTests(unittest.TestCase):
    def test_serves_health_and_latest(self):
        with tempfile.TemporaryDirectory() as tmp:
            store = FileStore(tmp)
            report_path = store.write(json.dumps({"ok": True}), "2024-01-01T00:00:00Z").path
            self.assertTrue(os.path.exists(report_path))

            port = available_port()
            server = ReportServer("127.0.0.1", port, store)
            http_server = server.start_in_background()

            time.sleep(0.05)
            with urllib.request.urlopen(f"http://127.0.0.1:{port}/health") as response:
                body = response.read().decode("utf-8")
                self.assertEqual(body, "ok")

            with urllib.request.urlopen(f"http://127.0.0.1:{port}/latest") as response:
                data = json.loads(response.read().decode("utf-8"))
                self.assertTrue(data["ok"])

            http_server.shutdown()
            http_server.server_close()


if __name__ == "__main__":
    unittest.main()
