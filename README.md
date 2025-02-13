# Magic Project 🚀

```
     /-\
    |o o|
    |>-<|
   /|   |\
  / |___| \
    |   |
    |   |
   /     \
   
```

## Overview
Magic Project is a modern customer feedback system built with FastAPI and deployed on Google Cloud Run. The project implements a complete CI/CD pipeline using GitLab and Github Actions CI/CD and infrastructure as code using Terraform.

## Quick Start

### Prerequisites
- Python 3.9+
- Docker
- Terraform
- Google Cloud SDK
- GitLab Account
- Github Account
- Patient a lot of Patient

### Local Development
```bash
# Install dependencies
pip install -r src/api/requirements.txt

# Run the API locally
python src/api/main.py
```

### Test the API
```bash
# Health check
curl http://localhost:8080/health

# Submit feedback
curl -X POST http://localhost:8080/feedback \
-H "Content-Type: application/json" \
-d '{"customer_id": "12345", "message": "Great service!", "rating": 5}'
Todo other curl example 
```

## Project Structure
```
magic-project/
├── src/
│   └── api/               # FastAPI application
├── terraform/
│   ├── environments/      # Environment-specific configurations
│   └── modules/          # Reusable Terraform modules
└── tests/                # Test suites
```

## Deployment
The project uses Terraform for infrastructure management and GitLab CI/CD for automated deployments.

### Staging
```bash
cd terraform/environments/staging
terraform init
terraform apply
```

### Production
```bash
cd terraform/environments/prod
terraform init
terraform apply
```

## Features
- 🚀 FastAPI-based RESTful API
- 🔒 Secure by default
- 🏗️ Infrastructure as Code with Terraform
- 📦 Containerized with Docker
- 🔄 Automated CI/CD pipeline
- ⚡ Deployed on Google Cloud Run

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)