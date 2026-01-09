from __future__ import annotations

import argparse
import logging
import os
import sys

from .config import Config
from .runner import Runner
from .server import ReportServer
from .storage import FileStore
from .version import VERSION


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="webperfmonitor")
    parser.add_argument("command", nargs="?", default="run-once")
    parser.add_argument("--config", "-c", default="", help="Path to TOML config")
    parser.add_argument("--version", action="store_true", help="Print version and exit")
    return parser


def configure_logging() -> None:
    level_name = os.getenv("LOG_LEVEL", "INFO").upper()
    level = getattr(logging, level_name, logging.INFO)
    logging.basicConfig(level=level, format="%(levelname)s %(message)s")


def run_once(config: Config) -> None:
    runner = Runner(config.settings)
    result = runner.run_once()
    print(f"Report written to {result.output.path} ({result.output.bytes_written} bytes)")
    if result.webhook_result:
        print(f"Webhook: {result.webhook_result.message}")


def run_forever(config: Config) -> None:
    runner = Runner(config.settings)
    runner.run_forever()


def serve(config: Config) -> None:
    if not config.settings.server.enabled:
        raise SystemExit("Server disabled in config. Set server.enabled=true to run.")
    store = FileStore(config.settings.report_output_dir)
    server = ReportServer(config.settings.server.host, config.settings.server.port, store)
    server.start()


def main(argv: list[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.version:
        print(VERSION)
        return

    configure_logging()
    config = Config.load(args.config or None)

    if args.command == "run-once":
        run_once(config)
    elif args.command == "monitor":
        run_forever(config)
    elif args.command == "serve":
        serve(config)
    elif args.command == "validate-config":
        print("Config OK")
    elif args.command == "print-config":
        print(config.settings.to_toml())
    else:
        print(f"Unknown command: {args.command}")
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
