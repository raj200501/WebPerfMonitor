from __future__ import annotations

import dataclasses
import os
import tomllib
from dataclasses import dataclass
from typing import Any, Dict, Optional
from urllib.parse import urlparse


class ConfigError(ValueError):
    pass


@dataclass
class Thresholds:
    warning_seconds: float = 0.5
    critical_seconds: float = 1.5

    def validate(self) -> None:
        if self.warning_seconds <= 0 or self.critical_seconds <= 0:
            raise ConfigError("Thresholds must be greater than zero")
        if self.warning_seconds >= self.critical_seconds:
            raise ConfigError("Warning threshold must be lower than critical threshold")


@dataclass
class ServerSettings:
    enabled: bool = False
    host: str = "127.0.0.1"
    port: int = 4000

    def validate(self) -> None:
        if self.port <= 0 or self.port > 65535:
            raise ConfigError("Server port must be between 1 and 65535")


@dataclass
class Settings:
    websites: list[str]
    monitor_interval_seconds: int = 60
    request_timeout_seconds: float = 5.0
    report_output_dir: str = "reports"
    webhook_url: Optional[str] = None
    thresholds: Thresholds = dataclasses.field(default_factory=Thresholds)
    server: ServerSettings = dataclasses.field(default_factory=ServerSettings)

    def validate(self) -> None:
        if not self.websites:
            raise ConfigError("At least one website must be configured")
        for website in self.websites:
            parsed = urlparse(website)
            if not parsed.scheme or not parsed.netloc:
                raise ConfigError(f"Invalid website URL: {website}")
        if self.monitor_interval_seconds <= 0:
            raise ConfigError("Monitor interval must be greater than zero")
        if self.request_timeout_seconds <= 0:
            raise ConfigError("Request timeout must be greater than zero")
        if not self.report_output_dir.strip():
            raise ConfigError("Report output dir cannot be empty")
        self.thresholds.validate()
        self.server.validate()

    @classmethod
    def from_dict(cls, payload: Dict[str, Any]) -> "Settings":
        thresholds = Thresholds(**payload.get("thresholds", {}))
        server = ServerSettings(**payload.get("server", {}))
        webhook_url = payload.get("webhook_url") or None
        return cls(
            websites=list(payload.get("websites", [])),
            monitor_interval_seconds=payload.get("monitor_interval_seconds", 60),
            request_timeout_seconds=payload.get("request_timeout_seconds", 5.0),
            report_output_dir=payload.get("report_output_dir", "reports"),
            webhook_url=webhook_url,
            thresholds=thresholds,
            server=server,
        )

    def to_toml(self) -> str:
        webhook = self.webhook_url or ""
        return (
            "websites = [" + ", ".join([f"\"{url}\"" for url in self.websites]) + "]\n"
            f"monitor_interval_seconds = {self.monitor_interval_seconds}\n"
            f"request_timeout_seconds = {self.request_timeout_seconds}\n"
            f"report_output_dir = \"{self.report_output_dir}\"\n"
            f"webhook_url = \"{webhook}\"\n\n"
            "[thresholds]\n"
            f"warning_seconds = {self.thresholds.warning_seconds}\n"
            f"critical_seconds = {self.thresholds.critical_seconds}\n\n"
            "[server]\n"
            f"enabled = {str(self.server.enabled).lower()}\n"
            f"host = \"{self.server.host}\"\n"
            f"port = {self.server.port}\n"
        )


@dataclass
class Config:
    settings: Settings

    DEFAULT_PATH = "config/default.toml"

    @classmethod
    def load(cls, path: Optional[str] = None) -> "Config":
        config_path = path or cls.DEFAULT_PATH
        if os.path.exists(config_path):
            with open(config_path, "rb") as handle:
                payload = tomllib.load(handle)
            settings = Settings.from_dict(payload)
        else:
            settings = Settings(websites=["https://example.com"])
        settings.validate()
        return cls(settings=settings)
