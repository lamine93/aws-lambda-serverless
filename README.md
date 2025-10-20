## 🚀 Serverless IaC Deployment with Terraform (AWS Lambda + API Gateway + DynamoDB)

This project demonstrates how to build and deploy a fully serverless REST API on AWS using Infrastructure as Code (IaC) with Terraform.
It covers compute, API, database, IAM roles, authentication, and CORS — all provisioned automatically.

## 🧠 Architecture (Mermaid)

```mermaid
flowchart TD
    User -->|HTTPS| API[API Gateway]
    API -->|Invoke| Lambda[Lambda Function]
    Lambda -->|Read/Write| DynamoDB[(DynamoDB)]
    Cognito[Cognito User Pool] --> API
    API --> CloudWatch[CloudWatch Logs]

