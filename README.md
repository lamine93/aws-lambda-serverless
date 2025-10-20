## 🚀 Serverless IaC Deployment with Terraform (AWS Lambda + API Gateway + DynamoDB)

This project demonstrates how to build and deploy a fully serverless REST API on AWS using Infrastructure as Code (IaC) with Terraform.
It covers compute, API, database, IAM roles, authentication, and CORS — all provisioned automatically.

## 🧩 Serverless Architecture

```mermaid
flowchart LR
    subgraph Frontend
      A[Amplify Web App]
    end

    subgraph Auth
      B[(Cognito User Pool)]
    end

    subgraph Backend
      C[API Gateway]
      D[Lambda Function]
    end

    subgraph Data
      E[(DynamoDB Table)]
    end

    subgraph Monitoring
      F[(CloudWatch Logs)]
    end

    A -->|Sign in| B
    B -->|JWT Token| C
    C -->|Invoke| D
    D -->|Read/Write| E
    D -->|Log| F
```

## ⚙️ Technologies Used

| Component | AWS Service | Description |
|------------|--------------|-------------|
| **Frontend** | Amplify / S3 | Static web hosting with HTTPS |
| **Authentication** | Cognito | OAuth2 / JWT user management |
| **API** | API Gateway (HTTP) | Public REST API with CORS and auth |
| **Compute** | Lambda (Python) | Stateless serverless compute |
| **Database** | DynamoDB | Serverless NoSQL table for users |
| **Monitoring** | CloudWatch Logs | Lambda logging and metrics |
| **Infrastructure** | Terraform | Infrastructure as Code (IaC) deployment |

