"""FastAPI application entry point."""

from fastapi import FastAPI

from app.api.health import router as health_router
from app.core.config import get_settings
from app.core.exceptions import register_exception_handlers
from app.core.logging import configure_logging


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""

    settings = get_settings()
    configure_logging(settings)

    app = FastAPI(title=settings.app_name, version=settings.app_version)
    app.include_router(health_router)
    register_exception_handlers(app)
    return app


app = create_app()
