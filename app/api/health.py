"""Health check API routes."""

from typing import Literal

from fastapi import APIRouter, status
from pydantic import BaseModel

from app.core.config import get_settings
from app.core.database import check_database

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    """Response schema for the health endpoint."""

    application: Literal["ok"]
    name: str
    version: str
    database: Literal["ok", "unavailable"]


@router.get("/health", response_model=HealthResponse, status_code=status.HTTP_200_OK)
def health() -> HealthResponse:
    """Return application and database health status."""

    settings = get_settings()
    database_status: Literal["ok", "unavailable"] = "ok"
    try:
        check_database()
    except Exception:
        database_status = "unavailable"

    return HealthResponse(
        application="ok",
        name=settings.app_name,
        version=settings.app_version,
        database=database_status,
    )
