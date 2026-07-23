"""Application configuration loaded from environment variables."""

from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime settings for the Elinor CRM API."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = Field(default="Elinor CRM", alias="APP_NAME")
    environment: str = Field(default="development", alias="ENVIRONMENT")
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = Field(
        default="INFO",
        alias="LOG_LEVEL",
    )
    database_url: str = Field(
        default="postgresql+psycopg://elinor:elinor@localhost:5432/elinor_crm",
        alias="DATABASE_URL",
    )
    database_health_timeout_seconds: float = Field(
        default=2.0,
        alias="DATABASE_HEALTH_TIMEOUT_SECONDS",
        gt=0,
    )


@lru_cache
def get_settings() -> Settings:
    """Return cached application settings."""

    return Settings()
