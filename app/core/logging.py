"""Logging configuration for the Elinor CRM API."""

import logging

from app.core.config import Settings


def configure_logging(settings: Settings) -> None:
    """Configure standard library logging for the application."""

    logging.basicConfig(
        level=settings.log_level,
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
    )
