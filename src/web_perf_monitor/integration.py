from __future__ import annotations

import urllib.error
import urllib.request

from .models import WebhookResult


class WebhookClient:
    def __init__(self, endpoint: str) -> None:
        self._endpoint = endpoint

    def send(self, report_json: str) -> WebhookResult:
        request = urllib.request.Request(
            self._endpoint,
            data=report_json.encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=10) as response:
                status_code = response.status
            if 200 <= status_code < 300:
                return WebhookResult(True, status_code, "Webhook delivered")
            return WebhookResult(False, status_code, f"Webhook failed with status {status_code}")
        except urllib.error.HTTPError as exc:
            return WebhookResult(False, exc.code, f"Webhook failed with status {exc.code}")
        except Exception as exc:  # noqa: BLE001
            return WebhookResult(False, None, f"Webhook failed: {exc}")
