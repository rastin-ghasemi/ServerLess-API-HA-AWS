# 🌍 Production-Grade Multi-Region Serverless Architecture

## Terraform \| AWS \| High Availability \| Disaster Recovery

------------------------------------------------------------------------

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?logo=amazon-aws)
![Architecture](https://img.shields.io/badge/Design-Multi--Region-blue)
![Status](https://img.shields.io/badge/Deployment-Production--Style-success)

------------------------------------------------------------------------

## 📌 Executive Summary

This project demonstrates a **real-world, production-style multi-region
serverless architecture on AWS**, fully provisioned using Terraform.

It implements:

-   🌎 Multi-region deployment (us-east-1 / us-west-2)
-   🔁 Automated DNS failover (Active-Standby)
-   ⚡ Serverless compute (AWS Lambda)
-   🗄 DynamoDB Global Table replication
-   🔐 Regional ACM certificates
-   🌐 Custom domain per region
-   📊 Health monitoring via Route 53
-   🔒 Remote Terraform backend with state locking

This architecture is designed for:

-   High Availability
-   Disaster Recovery
-   Business Continuity
-   Cloud-native scalability

------------------------------------------------------------------------

# 🏗 High-Level Architecture

                    Route 53 (Failover Routing)
                             |
                       api.domain.com
                             |
        ------------------------------------------------
        |                                              |

Primary (us-east-1) Secondary (us-west-2) \| \| API Gateway API Gateway
\| \| Lambda (Read/Write) Lambda (Read/Write) \| DynamoDB Global Table
(Cross-Region Replication)

------------------------------------------------------------------------

# 🔥 Core Architectural Decisions

## 1️⃣ Active--Standby Failover Strategy

-   Primary region handles all traffic under normal conditions.
-   Route 53 health checks continuously monitor availability.
-   Automatic failover occurs when primary becomes unhealthy.
-   Zero manual intervention required.

This mirrors real enterprise disaster recovery patterns.

------------------------------------------------------------------------

## 2️⃣ Serverless-First Design

-   No EC2
-   No Load Balancers
-   Fully managed services
-   PAY_PER_REQUEST DynamoDB billing

Benefits:

-   Cost efficiency
-   Operational simplicity
-   Automatic scaling
-   Reduced infrastructure overhead

------------------------------------------------------------------------

## 3️⃣ Read / Write Separation

  Method   Endpoint   Lambda
  -------- ---------- ---------------
  GET      /read      ReadFunction
  POST     /write     WriteFunction

Advantages:

-   Separation of concerns
-   Easier scaling logic
-   Cleaner security boundaries
-   Production-aligned API structure

------------------------------------------------------------------------

# 📂 Repository Structure

    .
    ├── Provider.tf                     # Multi-region provider aliasing
    ├── Main.tf                         # Core config
    ├── terraform.tf                    # Backend configuration
    ├── var.tf                          # Variables
    ├── output.tf                       # Outputs
    │
    ├── API.tf                          # API Gateway
    ├── acm.tf                          # ACM certificates per region
    ├── custom-api-domain.tf            # Domain mappings
    ├── health-check.tf                 # Route 53 health checks
    ├── Dynamodb-Multi-Region.tf        # Global table setup
    ├── IAM.tf                          # IAM roles & policies
    ├── Lambada.tf                      # Lambda definitions
    │
    ├── read_function.zip
    ├── write_function.zip
    ├── index.html

------------------------------------------------------------------------

# 📊 Disaster Recovery Workflow

1.  Route 53 checks `/read` endpoint in primary region.
2.  If health check fails:
    -   PRIMARY record marked unhealthy.
    -   Traffic shifts automatically to SECONDARY.
3.  Secondary region continues serving requests.
4.  DynamoDB Global Table ensures replicated state.

Recovery Time Objective (RTO): DNS propagation dependent.\
Recovery Point Objective (RPO): Near-zero (cross-region replication).

------------------------------------------------------------------------

# 🔐 Security Considerations

-   Regional IAM roles per Lambda
-   Explicit API Gateway invoke permissions
-   ACM DNS validation
-   Remote state encryption (S3 backend)

Production Enhancement Recommendations:

-   Replace FullAccess policies with least-privilege IAM
-   Add AWS WAF
-   Enable API Gateway access logging
-   Add CloudWatch alarms

------------------------------------------------------------------------

# 💰 Cost Model

Current pattern: Active-Standby

-   Both regions provisioned
-   Only primary receives traffic

Potential optimizations:

-   Active-Active latency routing
-   Canary deployments with Lambda aliases
-   Conditional secondary scaling strategy

------------------------------------------------------------------------

# 🚀 Deployment Instructions

``` bash
terraform init
terraform plan
terraform apply
```

Prerequisites:

-   Existing Route 53 hosted zone
-   Valid domain name
-   S3 backend bucket
-   DynamoDB lock table

------------------------------------------------------------------------

# 🧠 Professional Impact

This project demonstrates:

-   Advanced Terraform multi-region orchestration
-   Real disaster recovery design
-   DNS-based automated failover
-   Cloud-native architectural thinking
-   Production-grade AWS infrastructure skills

Ideal for:

-   DevOps Engineer roles
-   Cloud Engineer positions
-   SRE interviews
-   AWS Solutions Architect paths

------------------------------------------------------------------------

👨‍💻 Engineered for resilience, availability, and real-world production
scenarios.