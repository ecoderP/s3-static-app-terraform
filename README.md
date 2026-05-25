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

mv terraform.tfvarsbackendexample terraform.tfvars
```

2. In the terraform/bootstrap folder

- Personalise variables
- Initialise terraform

```
terraform init
```

**_Important:_** Copy the bucket name from terminal output. This is the shared backend state bucket name for all environments. Use this output as bucket name in .tfbackend for all environments.

4. Configure environment

Each environment (dev/staging/prod) has its own configuration. Locate .tfbackend and .tfvars configuration files, personalise and rename for each environment. For example, for dev environment:

```
cd terraform/environments/dev

mv dev.tfbackendexample dev.tfbackend

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

---

## 🧱 Infrastructure Teardown

1. From each environment directory (dev, staging and prod), run the command:

```
terraform destroy -auto-approve
```

Do this for all environments.

2. From the terraform **_bootstrap_** directory, run the command:

```
terraform destroy -auto-approve

```

3. Optional, but can do: List all AWS buckets in your account and confirmbuckets are not listed. Run the command:

```
aws s3 ls

```

---

## 📚 Lessons Learned

### 1. Infrastructure Modularity Matters Early

Breaking infrastructure into reusable Terraform modules made the project significantly easier to maintain and scale across environments.

Separating:

- S3 configuration
- CloudFront setup
- IAM/OIDC authentication

allowed infrastructure changes to be isolated without affecting the entire stack.

### 2. OIDC Authentication Is More Secure Than Long-Lived AWS Keys

Using GitHub OIDC federation eliminated the need to store AWS access keys in GitHub Secrets.

This project provided hands-on experience with:

- IAM trust policies
- federated authentication
- least-privilege access design

and highlighted modern cloud security best practices.

### 3. Environment Isolation Prevents Deployment Drift

Separating dev, staging, and production infrastructure reduced accidental cross-environment changes and improved deployment confidence.

This also made testing infrastructure changes safer before promoting them to production.

### 4. Terraform State Management Requires Planning

Managing Terraform state becomes increasingly important as infrastructure grows.

This project reinforced:

- the importance of remote state backends
- state locking
- consistent environment structure
- predictable resource naming conventions

### 5. CI/CD Pipelines Are Infrastructure Too

A deployment pipeline should be treated as part of the infrastructure rather than an afterthought.

Automating:

- builds
- deployments
- authentication
- CloudFront invalidations

improved reliability and reduced manual deployment errors.

### 6. Small AWS Misconfigurations Can Cause Large Failures

Minor IAM or bucket policy mistakes can completely break deployments.

Troubleshooting issues such as:

- AccessDenied errors
- incorrect OIDC trust relationships
- CloudFront origin permissions
- S3 bucket policy conflicts

helped build deeper AWS troubleshooting skills.

### 7. Reusability Requires Intentional Design

Making a project reusable is not automatic.

It required:

- parameterized Terraform variables
- environment abstraction
- clean module boundaries
- predictable naming conventions

This project reinforced the importance of designing for reuse from the beginning rather than trying to fix it later.

### 8. Production Infrastructure Requires Both Security and Automation

A working deployment is not necessarily production-ready.

This project highlighted the balance between:

- security
- scalability
- automation
- maintainability
- developer experience

when building real-world cloud infrastructure.

### 9. Documentation Is Part of Engineering

Clear documentation became essential as the project grew in complexity.

Writing reusable setup instructions and architecture explanations can improve:

- onboarding
- maintainability
- troubleshooting
- long-term project usability

---

## 📈 Future Improvements

- Add custom domain + Route53 automation
- ACM SSL certificate provisioning
- Automated performance testing in CI

---

## 👨‍💻 Author

Built and Maintained by [ecoderP](https://github.com/ecoderP)
