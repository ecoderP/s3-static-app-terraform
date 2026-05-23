terraform init -migrate-state -backend-config=dev.tfbackend
terraform init -reconfigure -backend-config=dev.tfbackend

# Just commenting random stuff for debugging

- name: Debug GitHub Context
  run: |
  echo "Repository: ${{ github.repository }}"
  echo "Ref: ${{ github.ref }}"
  echo "Environment: prod"

# 🚀 Terraform S3 Static App Project ( Reusable and Self-bootstrapping)

A **reusable, self-bootstrapping infrastructure template** for deploying modern **React (Vite) static applications** to AWS using:

- 🪣 Amazon S3 (static hosting)
- 🌍 Amazon CloudFront (global CDN)
- 🔐 AWS IAM + GitHub OIDC (secure CI/CD authentication)
- ⚙️ Terraform (infrastructure as code)
- ⚡ GitHub Actions (multi-environment CI/CD: dev, staging, prod)

This project is designed as a **drop-in frontend deployment foundation** for any Vite + React application that needs scalable AWS hosting with automated deployments.

---

## 🧱 Architecture Overview

This system provisions and connects:

- **React + Vite App**
  - Built and deployed via GitHub Actions

- **S3 Bucket**
  - Stores built static assets
  - Private bucket (no public access)

- **CloudFront Distribution**
  - Serves content globally
  - Handles caching and HTTPS

- **IAM OIDC Role (GitHub Actions)**
  - Secure, keyless AWS authentication
  - Least privilege access for deployment

- **Terraform Modules**
  - S3 static site module
  - CloudFront module
  - IAM OIDC module
  - Environment-based configuration

---

## 📁 Project Structure

```
.
├── src/                          # React (Vite) application source code
│
├── public/                       # Static assets served directly (faviconimages, etc.)
│
├── index.html                    # Vite entry HTML file
├── package.json + other configs  # Project dependencies and scripts
│
├── terraform/                    # Infrastructure as Code (Terraform) directory
│   │
│   ├── bootstrap/                # One-time setup (state backend, foundational resource)
│   │
│   ├── modules/                  # Reusable Terraform modules
│   │   │
│   │   ├── s3-static-site/       # S3 bucket + static hosting configuration
│   │   ├── cloudfront/           # CloudFront CDN distribution setup
│   │   ├── iam-oidc/            # GitHub Actions OIDC IAM role configuration
│   │
│   ├── environments/             # Environment-specific configurations
│   │   │
│   │   ├── dev/                  # Development environment
│   │   ├── staging/              # Staging environment
│   │   ├── prod/                 # Production environment
│
├── .github/workflows/           # CI/CD pipelines (GitHub Actions)
│   ├── deploy-dev.yml           # Dev deployment workflow
│   ├── deploy-staging.yml       # Staging deployment workflow
│   ├── deploy-prod.yml          # Production deployment workflow
│
└── README.md                     # Project documentation

```

---

## ⚡ Features

This project was built with:

- Fully automated CI/CD pipeline (GitHub Actions)
- Secure AWS authentication using OIDC (no long-lived AWS keys)
- Environment-based deployments (dev / staging / prod)
- CloudFront invalidation on every deployment
- Reusable Terraform modules for multi-project usage
- Production-ready S3 security configuration
- Clean separation of infrastructure and frontend build

---

## 📦 Prerequisites

Before using this project, ensure you have:

- AWS Account
- Terraform ≥ 1.10+ (Required for S3 file lock feature introduced in v.1.10. enabling file lock in S3 allows us to lock our state file without the need for DynamoDB + S3 lock feature which is being deprecated by AWS)
- Node.js ≥ 20+
- GitHub repository
- AWS CLI configured (for local testing)

---

## 🚀 Getting Started

1. Clone the repository

```
git clone https://github.com/ecoderP/s3-static-app-terraform.git
```

### Before you continue, Please note:

- There are preset customisable terraform variables in .tfvarsexample.
- Terraform state backend configurations are in .tfbackendexample files.

These are so named to bypass .gitignore. Gitgnore will ignore all .tfvars and .tfbackend files for security. You will need to rename .tfvarsexample and .tfbackendexample to .tfvars and .tfbackend extensions respectively.

For example, for terraform/bootstrap/ directory, update configuration settings, then:

```
cd terraform/bootstrap

cp terraform.tfvarsbackendexample terraform.tfvars
```

2. In the terraform/bootstrap folder

- Personalise variables
- Initialise terraform

```
terraform init
```

**_Important:_** Copy the bucket name from terminal output. This is the shared backend state bucket name for all environments. Use this output as bucket name in .tfbackend for all environments.

4. Configure environment

Each environment (dev/staging/prod) has its own configuration. Locate .tfbackend and .tfvars configuration files, personalise and rename for each environment.

```
cd terraform/environments/dev

cp dev.tfbackendexample dev.tfbackend

terraform init -backend-config=dev.tfbackend
```

5. Validate code and Deploy Infrastructure for each environment

```
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## 🔐 GitHub OIDC Authentication

This project uses GitHub Actions → AWS OIDC federation, meaning:

✔ No AWS access keys stored in GitHub

✔ Temporary credentials issued per workflow run

✔ Least-privilege IAM roles scoped per environment

### IAM Role Trust Relationship

GitHub Actions assumes a role like:

- Repository: Your-github-username/repo-name
- Branch-based conditions:
  - dev → dev role
  - staging → staging role
  - main → production role

---

## ⚙️ CI/CD Pipeline

This project includes GitHub Actions workflows for:

### 🧪 Dev Deployment

- Trigger: push to dev
- Deploys to dev S3 bucket + CloudFront

### 🧱 Staging Deployment

- Trigger: push to staging
- Deploys to staging S3 bucket + CloudFront
- Used for pre-production validation

### 🚀 Production Deployment

- Trigger: push to main
- Deploys stable build to production environment (S3 + CloudFront)

### CI/CD Flow

1. Checkout code
2. Install dependencies
3. Build Vite React app
4. Assume AWS role via OIDC
5. Sync build to S3
6. Invalidate CloudFront cache

### Important GitHub Actions secrets

To get your CI/CD pipeline working, add the following environment secrets to GitHub Actions:

- S3_BUCKET
- CLOUDFRONT_DISTRIBUTION_ID
- AWS_ROLE_ARN

To get the values for your secrets, from each environment directory (dev, staging, prod), run:

```
terraform output
```

---

## ♻️ Re-using This Project (Some Viable Options)

This repo is designed as a starter backend infrastructure for any React + Vite frontend project.

### Option 1: Use as a Terraform Module

```
module "frontend_hosting" {
  source = "github.com/ecoderP/s3-static-app-terraform//modules/s3-static-site"

  bucket_name = "my-new-app"
  environment = "dev"
}
```

### Option 2: Multi-App Scaling

You can reuse this setup for:

- Portfolio sites
- SaaS frontend dashboards
- Admin panels
- Marketing landing pages
- Micro-frontends

Just change:

- bucket name
- CloudFront config
- environment variables

---

## 🔐 Security Highlights

- S3 bucket is private by default
- CloudFront serves as the only public entry point
- IAM follows least privilege principle
- GitHub Actions uses short-lived credentials (OIDC)
- No hardcoded secrets in repo

---

## 📈 Future Improvements

- Add custom domain + Route53 automation
- ACM SSL certificate provisioning
- Automated performance testing in CI

---

## 👨‍💻 Author

Built and Maintained by [ecoderP](https://github.com/ecoderP)
