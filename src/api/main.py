# src/api/main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Dict
import uvicorn
import os

app = FastAPI(title="Magic API", description="API for handling customer feedback")

# Pydantic models
class FeedbackInput(BaseModel):
    customer_id: str
    message: str
    rating: int
    category: Optional[str] = None

class FeedbackUpdate(BaseModel):
    message: Optional[str] = None
    rating: Optional[int] = None
    category: Optional[str] = None

class FeedbackResponse(BaseModel):
    id: str
    customer_id: str
    message: str
    rating: int
    category: Optional[str] = None
    status: str = "received"

# In-memory storage for demo purposes
feedback_store: Dict[str, FeedbackResponse] = {}

@app.get("/")
async def read_root():
    return {"status": "healthy", "service": "Magic Feedback API"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/feedback", response_model=FeedbackResponse)
async def create_feedback(feedback: FeedbackInput):
    """Create a new feedback entry"""
    if not 1 <= feedback.rating <= 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")
    
    feedback_id = str(len(feedback_store) + 1)
    
    feedback_response = FeedbackResponse(
        id=feedback_id,
        customer_id=feedback.customer_id,
        message=feedback.message,
        rating=feedback.rating,
        category=feedback.category
    )
    
    feedback_store[feedback_id] = feedback_response
    return feedback_response

@app.get("/feedback/list", response_model=List[FeedbackResponse])
async def list_feedback():
    """List all feedback entries"""
    return list(feedback_store.values())

@app.get("/feedback/{feedback_id}", response_model=FeedbackResponse)
async def get_feedback(feedback_id: str):
    """Get a specific feedback by ID"""
    if feedback_id not in feedback_store:
        raise HTTPException(status_code=404, detail="Feedback not found")
    return feedback_store[feedback_id]

@app.put("/feedback/{feedback_id}", response_model=FeedbackResponse)
async def update_feedback(feedback_id: str, feedback_update: FeedbackUpdate):
    """Update an existing feedback"""
    if feedback_id not in feedback_store:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    current_feedback = feedback_store[feedback_id]
    
    update_data = feedback_update.dict(exclude_unset=True)
    
    if 'rating' in update_data and not 1 <= update_data['rating'] <= 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")
    
    for field, value in update_data.items():
        setattr(current_feedback, field, value)
    
    feedback_store[feedback_id] = current_feedback
    return current_feedback

@app.delete("/feedback/{feedback_id}", response_model=FeedbackResponse)
async def delete_feedback(feedback_id: str):
    """Delete a feedback by ID"""
    if feedback_id not in feedback_store:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    deleted_feedback = feedback_store.pop(feedback_id)
    return deleted_feedback

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)