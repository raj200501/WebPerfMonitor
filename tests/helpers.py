from __future__ import annotations

import socket
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import Callable


def available_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def start_server(handler: type[BaseHTTPRequestHandler], port: int) -> HTTPServer:
    server = HTTPServer(("127.0.0.1", port), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def stop_server(server: HTTPServer) -> None:
    server.shutdown()
    server.server_close()


class SimpleHandler(BaseHTTPRequestHandler):
    response_code = 200
    response_body = b"ok"

    def do_GET(self):  # noqa: N802
        self.send_response(self.response_code)
        self.end_headers()
        self.wfile.write(self.response_body)

    def do_POST(self):  # noqa: N802
        self.send_response(self.response_code)
        self.end_headers()
        self.wfile.write(self.response_body)

    def log_message(self, format, *args):
        return


class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):  # noqa: N802
        if self.path != "/webhook":
            self.send_response(404)
            self.end_headers()
            return
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok")

    def log_message(self, format, *args):
        return
