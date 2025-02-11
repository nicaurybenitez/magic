# Use official Python runtime as parent image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first for better cache usage
COPY requirements.txt .

# Install production dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m appuser && \
    chown -R appuser:appuser /app
USER appuser

# Set environment variables
ENV PORT=8080
ENV PYTHONUNBUFFERED=1

# Command to run the application
CMD exec gunicorn --bind :$PORT main:app -k uvicorn.workers.UvicornWorker --workers 1 --threads 8 --timeout 0