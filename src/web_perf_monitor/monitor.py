from __future__ import annotations

import time
import urllib.request
from typing import List

from .config import Settings
from .models import Metric


class Monitor:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def collect_metrics(self) -> List[Metric]:
        metrics = []
        for website in self._settings.websites:
            metrics.append(self._measure(website))
        return metrics

    def _measure(self, url: str) -> Metric:
        start = time.monotonic()
        try:
            request = urllib.request.Request(url, method="GET")
            with urllib.request.urlopen(request, timeout=self._settings.request_timeout_seconds) as response:
                response.read()
                status = response.status
            duration = time.monotonic() - start
            return Metric(url=url, response_time_seconds=duration, status_code=status)
        except Exception as exc:  # noqa: BLE001
            duration = time.monotonic() - start
            return Metric(url=url, response_time_seconds=duration, error=str(exc))
