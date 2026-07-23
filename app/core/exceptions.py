"""Application exception handlers."""

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse


async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Return a generic JSON response for uncaught exceptions."""

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"},
    )


def register_exception_handlers(app: FastAPI) -> None:
    """Register exception handlers on the FastAPI application."""

    app.add_exception_handler(Exception, unhandled_exception_handler)
