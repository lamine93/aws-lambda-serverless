🚀 Serverless IaC Deployment with Terraform (AWS Lambda + API Gateway + DynamoDB)

This project demonstrates how to build and deploy a fully serverless REST API on AWS using Infrastructure as Code (IaC) with Terraform.
It covers compute, API, database, IAM roles, authentication, and CORS — all provisioned automatically.

🧩 Architecture Overview
┌───────────────────────────┐
│        Frontend           │
│ (Amplify / S3 + Cognito)  │
└────────────┬──────────────┘
             │ HTTPS + Auth (JWT)
             ▼
┌───────────────────────────┐
│   API Gateway (HTTP API)  │
│  - CORS                   │
│  - Cognito Authentication │
└────────────┬──────────────┘
             │ Invoke
             ▼
┌───────────────────────────┐
│       Lambda Function     │
│  - Python runtime         │
│  - CRUD operations        │
│  - Access DynamoDB        │
└────────────┬──────────────┘
             │
             ▼
┌───────────────────────────┐
│     DynamoDB (NoSQL)      │
│  - Table "users"          │
│  - Partition key: id      │
└───────────────────────────┘
