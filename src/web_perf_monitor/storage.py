from __future__ import annotations

import glob
import os
from typing import Optional

from .models import ReportOutput


class FileStore:
    def __init__(self, output_dir: str) -> None:
        self._output_dir = output_dir

    def write(self, report_json: str, timestamp: str) -> ReportOutput:
        os.makedirs(self._output_dir, exist_ok=True)
        safe_timestamp = timestamp.replace(":", "-")
        path = os.path.join(self._output_dir, f"report-{safe_timestamp}.json")
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(report_json)
        return ReportOutput(path=path, bytes_written=len(report_json.encode("utf-8")))

    def latest_report_path(self) -> Optional[str]:
        if not os.path.isdir(self._output_dir):
            return None
        files = glob.glob(os.path.join(self._output_dir, "report-*.json"))
        return sorted(files)[-1] if files else None

    def read_latest(self) -> Optional[str]:
        path = self.latest_report_path()
        if not path:
            return None
        with open(path, "r", encoding="utf-8") as handle:
            return handle.read()
