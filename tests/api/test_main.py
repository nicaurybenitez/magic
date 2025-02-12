# src/api/tests/test_main.py
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "service": "Magic Feedback API"}

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_create_feedback():
    test_feedback = {
        "customer_id": "test123",
        "message": "Test feedback",
        "rating": 5
    }
    response = client.post("/feedback", json=test_feedback)
    assert response.status_code == 200
    assert response.json()["customer_id"] == test_feedback["customer_id"]
    assert response.json()["message"] == test_feedback["message"]
    assert response.json()["rating"] == test_feedback["rating"]

def test_invalid_rating():
    test_feedback = {
        "customer_id": "test123",
        "message": "Test feedback",
        "rating": 6  # Invalid rating > 5
    }
    response = client.post("/feedback", json=test_feedback)
    assert response.status_code == 400