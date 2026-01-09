from __future__ import annotations

import logging
import time
from dataclasses import dataclass
from typing import Optional

from .analyzer import Analyzer
from .config import Settings
from .integration import WebhookClient
from .models import ReportData, ReportOutput, WebhookResult
from .monitor import Monitor
from .recommendations import RecommendationEngine
from .report import ReportBuilder
from .storage import FileStore

logger = logging.getLogger("web_perf_monitor")


@dataclass
class RunResult:
    report: ReportData
    output: ReportOutput
    webhook_result: Optional[WebhookResult]


class Runner:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._monitor = Monitor(settings)
        self._analyzer = Analyzer()
        self._reporter = ReportBuilder()
        self._recommendation_engine = RecommendationEngine(settings.thresholds)
        self._store = FileStore(settings.report_output_dir)

    def run_once(self) -> RunResult:
        metrics = self._monitor.collect_metrics()
        analysis = self._analyzer.analyze(metrics)
        recommendations = self._recommendation_engine.generate(analysis)
        report = self._reporter.generate(metrics, analysis, recommendations)
        report_json = self._reporter.to_json(report, pretty=True)
        output = self._store.write(report_json, report.timestamp)
        webhook_result = self._send_webhook(report_json)
        return RunResult(report=report, output=output, webhook_result=webhook_result)

    def run_forever(self) -> None:
        while True:
            result = self.run_once()
            logger.info("Report written to %s", result.output.path)
            if result.webhook_result:
                logger.info("Webhook result: %s", result.webhook_result.message)
            time.sleep(self._settings.monitor_interval_seconds)

    def _send_webhook(self, report_json: str) -> Optional[WebhookResult]:
        if not self._settings.webhook_url:
            return None
        client = WebhookClient(self._settings.webhook_url)
        return client.send(report_json)
