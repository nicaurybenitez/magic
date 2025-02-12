# tests/api/test_main.py
from fastapi.testclient import TestClient
from src.api.main import app

# Create test client
client = TestClient(app=app)

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
        "rating": 5,
        "category": "general"
    }
    response = client.post("/feedback", json=test_feedback)
    assert response.status_code == 200
    response_data = response.json()
    assert response_data["customer_id"] == test_feedback["customer_id"]
    assert response_data["message"] == test_feedback["message"]
    assert response_data["rating"] == test_feedback["rating"]
    assert response_data["category"] == test_feedback["category"]
    assert "id" in response_data
    assert response_data["status"] == "received"

def test_invalid_rating():
    test_feedback = {
        "customer_id": "test123",
        "message": "Test feedback",
        "rating": 6  # Invalid rating > 5
    }
    response = client.post("/feedback", json=test_feedback)
    assert response.status_code == 400
    assert response.json()["detail"] == "Rating must be between 1 and 5"

def test_create_feedback_without_category():
    test_feedback = {
        "customer_id": "test123",
        "message": "Test feedback",
        "rating": 4
    }
    response = client.post("/feedback", json=test_feedback)
    assert response.status_code == 200
    response_data = response.json()
    assert response_data["category"] is None