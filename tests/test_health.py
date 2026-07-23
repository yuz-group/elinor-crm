"""Tests for the health endpoint."""

from collections.abc import Iterator
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client() -> Iterator[TestClient]:
    """Yield a TestClient instance."""

    with TestClient(app) as test_client:
        yield test_client


def test_health_returns_ok_when_database_is_available(client: TestClient) -> None:
    """Health endpoint reports a healthy app and database."""

    with patch("app.api.health.check_database", return_value=True):
        response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "application": "ok",
        "name": "Elinor CRM WEB",
        "version": "1.0.0",
        "database": "ok",
    }


def test_health_returns_unavailable_when_database_check_fails(client: TestClient) -> None:
    """Health endpoint reports database unavailability without failing."""

    with patch("app.api.health.check_database", side_effect=RuntimeError("offline")):
        response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "application": "ok",
        "name": "Elinor CRM WEB",
        "version": "1.0.0",
        "database": "unavailable",
    }
