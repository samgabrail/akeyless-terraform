# Akeyless + Terraform Integration Demo

This demo showcases how **Akeyless** integrates seamlessly with **Terraform** to provide secure, zero-trust secrets management for infrastructure as code.

## 🎯 Demo Overview

The demo is split into two parts that demonstrate both angles of Akeyless + Terraform integration:

### Part 1: Configure Akeyless with Terraform
- Set up Akeyless infrastructure using Terraform
- Create authentication methods, roles, and permissions
- Configure static secrets and dynamic secret producers
- Establish AWS targets for dynamic credential generation

### Part 2: Use Akeyless Secrets in Terraform
- Retrieve secrets from Akeyless during Terraform execution
- Use dynamic AWS credentials to authenticate AWS provider
- Deploy AWS infrastructure (S3 bucket) using secrets from Akeyless
- Demonstrate secure infrastructure provisioning

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │    │    Akeyless     │    │      AWS        │
│                 │    │                 │    │                 │
│ Part 1: Setup   │───▶│ Auth Methods    │    │                 │
│ • Auth Methods  │    │ Roles & Rules   │    │                 │
│ • Static Secrets│    │ Static Secrets  │    │                 │
│ • Dynamic Setup │    │ Dynamic Secrets │    │                 │
│                 │    │ AWS Target      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       ▲
┌─────────────────┐            │                       │
│   Terraform     │            │                       │
│                 │            ▼                       │
│ Part 2: Deploy  │    ┌─────────────────┐            │
│ • Retrieve      │◀───│  Retrieved      │            │
│   Secrets       │    │  Secrets:       │            │
│ • Use Dynamic   │    │  • Static API   │            │
│   AWS Creds     │    │  • Dynamic AWS  │────────────┘
│ • Deploy S3     │    │    Credentials  │
└─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

1. **Akeyless Account**: Sign up at [akeyless.io](https://akeyless.io)
2. **AWS Account**: With permissions to create IAM users and S3 buckets
3. **Terraform**: Version 1.6 or later
4. **AWS CLI**: Configured with credentials

### Step 1: Configure Akeyless Authentication

First, set up AWS IAM authentication in your Akeyless console:

1. Go to **Access** → **Auth Methods** → **New**
2. Select **AWS IAM**
3. Configure with your AWS account details
4. Note the **Access ID** - you'll need this for Part 1

### Step 2: Prepare Variables

Copy the example variable files:

```bash
# For Part 1
cd part1-akeyless-setup
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# For Part 2  
cd ../part2-infrastructure-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

Or use environment variables:
```bash
cp .env.example .env
# Edit .env with your values
source .env
```

### Step 3: Run Part 1 - Akeyless Setup

```bash
cd part1-akeyless-setup

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note the outputs - you'll need the auth method info for Part 2
terraform output
```

This creates:
- ✅ API Key authentication method
- ✅ Access role with proper permissions
- ✅ Static secrets (API key, DB config)
- ✅ AWS target for dynamic secrets
- ✅ AWS dynamic secret producer

### Step 4: Generate API Key for Part 2

In the Akeyless console:
1. Go to the authentication method created in Part 1
2. Generate new **Access ID** and **Access Key**
3. Update `part2-infrastructure-deployment/terraform.tfvars` with these values

### Step 5: Run Part 2 - Infrastructure Deployment

```bash
cd ../part2-infrastructure-deployment

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# View the outputs
terraform output
```

This demonstrates:
- 🔐 Retrieving static secrets from Akeyless
- 🔄 Getting dynamic AWS credentials from Akeyless
- 🪣 Using dynamic credentials to create S3 bucket
- 🏷️ Tagging resources with secret values (safely)

## 📁 File Structure

```
demo/
├── README.md                           # This file
├── .env.example                        # Environment variables template
├── cleanup.sh                          # Cleanup script
├── part1-akeyless-setup/
│   ├── main.tf                         # Akeyless infrastructure setup
│   ├── variables.tf                    # Input variables
│   ├── outputs.tf                      # Output values
│   └── terraform.tfvars.example        # Variables template
└── part2-infrastructure-deployment/
    ├── main.tf                         # AWS infrastructure deployment
    ├── variables.tf                    # Input variables
    ├── outputs.tf                      # Output values
    └── terraform.tfvars.example        # Variables template
```

## 🔒 Security Considerations

### ⚠️ Important Security Notes

1. **State File Security**: Secret values retrieved via data sources are stored in Terraform state files. Ensure your state files are:
   - Encrypted at rest (use S3 backend with encryption)
   - Access-controlled (limit who can read state files)
   - Never committed to version control

2. **Dynamic Credentials**: Dynamic AWS credentials from Akeyless automatically expire (1-hour TTL), reducing long-term exposure risk.

3. **Zero-Trust Architecture**: Akeyless uses fragment-based storage - secrets are never stored complete anywhere.

### Future Security Enhancements

- **Terraform 1.10+**: Introduces ephemeral resources that don't persist in state
- **Terraform 1.11+**: Adds write-only attributes for managed resources
- **Akeyless Roadmap**: Future support for these advanced Terraform security features

## 🎬 Demo Script

### Part 1 Demo (5-7 minutes)

1. **Introduction** (1 min)
   - Show the Terraform configuration files
   - Explain what will be created in Akeyless

2. **Deploy Configuration** (3-4 mins)
   - Run `terraform init` and `terraform plan`
   - Execute `terraform apply`
   - Show the resources being created in real-time

3. **Verify in Akeyless Console** (2 mins)
   - Navigate to Akeyless console
   - Show created auth methods, roles, secrets, and targets
   - Demonstrate the infrastructure-as-code approach

### Part 2 Demo (6-8 minutes)

1. **Generate API Key** (1 min)
   - Show how to generate access credentials from Part 1 auth method
   - Update terraform.tfvars

2. **Deploy Infrastructure** (4-5 mins)
   - Show the Terraform configuration that retrieves secrets
   - Run `terraform plan` - explain how secrets are retrieved
   - Execute `terraform apply`
   - Show AWS resources being created with dynamic credentials

3. **Verify Results** (2 mins)
   - Show created S3 bucket in AWS console
   - Demonstrate that secrets were used (check tags)
   - Show demo object with secret values

## 🧹 Cleanup

To destroy all resources created during the demo:

```bash
# Run the cleanup script
./cleanup.sh

# Or manually:
cd part2-infrastructure-deployment
terraform destroy

cd ../part1-akeyless-setup  
terraform destroy
```

## 🚧 Troubleshooting

### Common Issues

**Authentication Errors (Part 1)**
- Verify AWS IAM authentication is properly configured in Akeyless
- Check that `aws_iam_access_id` matches your Akeyless auth method
- Ensure AWS credentials have sufficient permissions

**Permission Errors (Part 2)**
- Verify the role created in Part 1 has proper access rules
- Check that API Key was generated from the correct auth method
- Ensure dynamic secret producer is properly configured

**AWS Credential Issues**
- Verify dynamic AWS credentials have proper IAM permissions
- Check that the AWS target in Akeyless is correctly configured
- Ensure the base AWS credentials can create IAM users

### Debug Commands

```bash
# Check Terraform state
terraform show

# Verify Akeyless connectivity
terraform providers

# AWS credential validation
aws sts get-caller-identity
```

## 📚 Additional Resources

- [Akeyless Terraform Provider Documentation](https://registry.terraform.io/providers/akeyless-community/akeyless/latest/docs)
- [Akeyless Documentation](https://docs.akeyless.io/)
- [Terraform Security Best Practices](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables)
- [AWS Dynamic Secrets with Akeyless](https://docs.akeyless.io/docs/aws-producer)

## 🤝 Contributing

This demo is part of the Akeyless + Terraform integration showcase. For questions or improvements:

1. Check the troubleshooting section above
2. Review the Akeyless documentation
3. Open an issue with detailed information about your setup

---

**Demo Summary**: This demonstrates how Akeyless provides zero-trust secrets management that integrates seamlessly with Terraform, enabling secure infrastructure-as-code workflows without compromising on security or operational simplicity.