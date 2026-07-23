"""Database engine and health check helpers."""

from collections.abc import Iterator

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import get_settings

settings = get_settings()
engine: Engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_timeout=settings.database_health_timeout_seconds,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Iterator[Session]:
    """Yield a database session for request-scoped dependencies."""

    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def check_database() -> bool:
    """Return True when the configured database accepts a simple query."""

    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))
    return True
