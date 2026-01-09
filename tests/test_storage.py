import os
import shutil
import unittest

from web_perf_monitor.storage import FileStore


class StorageTests(unittest.TestCase):
    def test_writes_and_reads_reports(self):
        output_dir = "tmp/test-storage"
        shutil.rmtree(output_dir, ignore_errors=True)

        store = FileStore(output_dir)
        output = store.write("{\"ok\": true}", "2024-01-01T00:00:00Z")

        self.assertTrue(os.path.exists(output.path))
        self.assertIn("ok", store.read_latest())


if __name__ == "__main__":
    unittest.main()
