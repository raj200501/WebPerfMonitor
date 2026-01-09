import json
import os
import socket
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

from web_perf_monitor.config import Settings, Thresholds, ServerSettings
from web_perf_monitor.runner import Runner


def available_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


class TargetHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        time.sleep(0.05)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok")

    def log_message(self, format, *args):
        return


class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/webhook":
            self.send_response(404)
            self.end_headers()
            return
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"received")

    def log_message(self, format, *args):
        return


def start_server(handler_cls, port: int) -> HTTPServer:
    server = HTTPServer(("127.0.0.1", port), handler_cls)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def main() -> None:
    target_port = available_port()
    webhook_port = available_port()
    report_dir = "tmp/smoke-reports"
    os.makedirs(report_dir, exist_ok=True)

    target_server = start_server(TargetHandler, target_port)
    webhook_server = start_server(WebhookHandler, webhook_port)

    settings = Settings(
        websites=[f"http://127.0.0.1:{target_port}"],
        monitor_interval_seconds=1,
        request_timeout_seconds=2.0,
        report_output_dir=report_dir,
        webhook_url=f"http://127.0.0.1:{webhook_port}/webhook",
        thresholds=Thresholds(warning_seconds=0.1, critical_seconds=1.0),
        server=ServerSettings(enabled=False, host="127.0.0.1", port=4001),
    )

    try:
        runner = Runner(settings)
        result = runner.run_once()

        if not os.path.exists(result.output.path):
            raise SystemExit(f"Expected report at {result.output.path}, but file is missing")

        with open(result.output.path, "r", encoding="utf-8") as handle:
            data = json.load(handle)

        url = data["metrics"][0]["url"]
        if url != f"http://127.0.0.1:{target_port}":
            raise SystemExit(f"Unexpected URL in report: {url}")

        if not result.webhook_result or not result.webhook_result.success:
            raise SystemExit("Expected webhook to be delivered")

        print("Smoke test passed")
    finally:
        target_server.shutdown()
        target_server.server_close()
        webhook_server.shutdown()
        webhook_server.server_close()


if __name__ == "__main__":
    main()
