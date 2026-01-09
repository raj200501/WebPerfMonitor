from __future__ import annotations

import logging
from http.server import BaseHTTPRequestHandler, HTTPServer
from threading import Thread
from typing import Optional

from .storage import FileStore

logger = logging.getLogger("web_perf_monitor")


class ReportHandler(BaseHTTPRequestHandler):
    store: Optional[FileStore] = None

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")
            return
        if self.path == "/latest":
            if not self.store:
                self.send_response(500)
                self.end_headers()
                return
            report = self.store.read_latest()
            if report:
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(report.encode("utf-8"))
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"No reports available")
            return
        self.send_response(404)
        self.end_headers()
        self.wfile.write(b"Not Found")

    def log_message(self, format: str, *args) -> None:  # noqa: A003
        return


class ReportServer:
    def __init__(self, host: str, port: int, store: FileStore) -> None:
        self._host = host
        self._port = port
        self._store = store
        self._server: Optional[HTTPServer] = None

    def start(self) -> None:
        handler = self._build_handler()
        self._server = HTTPServer((self._host, self._port), handler)
        logger.info("Report server listening on http://%s:%s", self._host, self._port)
        self._server.serve_forever()

    def start_in_background(self) -> HTTPServer:
        handler = self._build_handler()
        self._server = HTTPServer((self._host, self._port), handler)
        thread = Thread(target=self._server.serve_forever, daemon=True)
        thread.start()
        return self._server

    def shutdown(self) -> None:
        if self._server:
            self._server.shutdown()

    def _build_handler(self):
        store = self._store

        class BoundHandler(ReportHandler):
            pass

        BoundHandler.store = store
        return BoundHandler
