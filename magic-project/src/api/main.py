# main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import uvicorn
import os

app = FastAPI(title="Magic API", description="API for handling customer feedback")

# Pydantic model for feedback data validation
class FeedbackInput(BaseModel):
    customer_id: str
    message: str
    rating: int
    category: Optional[str] = None

class FeedbackResponse(BaseModel):
    id: str
    customer_id: str
    message: str
    rating: int
    category: Optional[str] = None
    status: str = "received"

# In-memory storage for demo purposes
# In production, this would be replaced with a database
feedback_store = {}

@app.get("/")
async def read_root():
    return {"status": "healthy", "service": "Magic Feedback API"}

@app.post("/feedback", response_model=FeedbackResponse)
async def create_feedback(feedback: FeedbackInput):
    # Validate rating range
    if not 1 <= feedback.rating <= 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")
    
    # Generate simple ID (in production, use UUID or similar)
    feedback_id = str(len(feedback_store) + 1)
    
    # Create feedback entry
    feedback_response = FeedbackResponse(
        id=feedback_id,
        customer_id=feedback.customer_id,
        message=feedback.message,
        rating=feedback.rating,
        category=feedback.category
    )
    
    # Store feedback
    feedback_store[feedback_id] = feedback_response
    
    return feedback_response

@app.get("/feedback/{feedback_id}")
async def get_feedback(feedback_id: str):
    if feedback_id not in feedback_store:
        raise HTTPException(status_code=404, detail="Feedback not found")
    return feedback_store[feedback_id]

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)