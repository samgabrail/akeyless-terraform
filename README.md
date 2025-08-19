# Akeyless + Terraform Integration Demo

This demo showcases how **Akeyless** integrates seamlessly with **Terraform** to provide secure, zero-trust secrets management for infrastructure as code.

## 🎯 Demo Overview

The demo is split into two parts that demonstrate both angles of Akeyless + Terraform integration:

### Part 1: Configure Akeyless with Terraform
- Set up Akeyless infrastructure using Terraform
- Create authentication methods, roles, and permissions
- Configure static secrets including database passwords and API keys
- Store configuration data for infrastructure deployment

### Part 2: Use Akeyless Secrets in Terraform
- Retrieve static secrets from Akeyless during Terraform execution
- Use retrieved configuration data to deploy AWS infrastructure
- Deploy AWS DynamoDB table with sample data
- Demonstrate secure infrastructure provisioning using static secrets

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │    │    Akeyless     │    │      AWS        │
│                 │    │                 │    │                 │
│ Part 1: Setup   │───▶│ Auth Methods    │    │                 │
│ • Auth Methods  │    │ Roles & Rules   │    │                 │
│ • Static Secrets│    │ Static Secrets  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       ▲
┌─────────────────┐            │                       │
│   Terraform     │            │                       │
│                 │            ▼                       │
│ Part 2: Deploy  │    ┌─────────────────┐            │
│ • Retrieve      │◀───│  Retrieved      │            │
│   Secrets       │    │  Secrets:       │            │
│ • Use Static    │    │  • DB Password  │            │
│   Secrets       │    │  • API Keys     │────────────┘
│ • Deploy DynamoDB│    │  • Config Data  │
└─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

1. **Akeyless Account**: Sign up at [akeyless.io](https://akeyless.io)
2. **AWS Account**: With permissions to create DynamoDB tables
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


### Step 4: Reset and Retrieve API Credentials for Part 2

After Part 1 completes, you need to reset the access key for the newly created authentication method to ensure credentials are not stored in Terraform state:

**Reset Access Key via Akeyless Console:**
1. Navigate to **Access** → **Auth Methods** in your Akeyless console
2. Find the auth method created in Part 1: `/terraform-demo/auth-method`
3. Click on the auth method and go to the **Access** tab
4. Click **Reset Access Key** to generate new credentials
5. Copy the new **Access ID** and **Access Key** 

**Update Part 2 Configuration:**
6. Edit `part2-infrastructure-deployment/terraform.tfvars`
7. Update the following values with your new credentials:
   ```hcl
   akeyless_access_id  = "p-xxxxxx"  # New Access ID from reset
   akeyless_access_key = "xxxxxxx"   # New Access Key from reset
   ```

> **Security Note**: We reset the access key to ensure that the credentials used in Part 2 are never stored in Terraform's state file from Part 1. This follows security best practices by keeping infrastructure setup credentials separate from runtime access credentials.

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
- 📊 Using configuration data to deploy infrastructure
- 🗄️ Creating DynamoDB table with retrieved settings
- 🏷️ Populating sample data using secure credentials

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
   - Encrypted at rest (use remote backend with encryption)
   - Access-controlled (limit who can read state files)
   - Never committed to version control

2. **Static Secrets Management**: While this demo uses static secrets for simplicity, Akeyless also supports dynamic credentials for advanced use cases.

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

1. **Reset and Retrieve API Credentials** (1-2 mins)
   - Navigate to the auth method created in Part 1
   - Reset the access key to generate fresh credentials
   - Explain why we reset (security best practice to avoid state storage)
   - Update terraform.tfvars with new credentials

2. **Deploy Infrastructure** (4-5 mins)
   - Show the Terraform configuration that retrieves static secrets
   - Run `terraform plan` - explain how secrets are retrieved at runtime
   - Execute `terraform apply`
   - Show DynamoDB table being created with retrieved configuration

3. **Verify Results** (2 mins)
   - Show created DynamoDB table in AWS console
   - Demonstrate that secrets were used to configure the table
   - Show sample data items populated in the table

## 🧹 Cleanup

To destroy all resources created during the demo, **follow this specific order** to avoid dependency issues:

```bash
# Run the cleanup script (automatically handles correct order)
./cleanup.sh

# Or manually (IMPORTANT: Destroy Part 2 first, then Part 1):

# Step 1: Destroy Part 2 Infrastructure (AWS resources)
cd part2-infrastructure-deployment
terraform destroy

# Step 2: Destroy Part 1 Infrastructure (Akeyless resources)
cd ../part1-akeyless-setup  
terraform destroy
```

> **⚠️ Cleanup Order is Critical**: Always destroy Part 2 before Part 1. Part 2 uses credentials and accesses secrets created in Part 1, so destroying Part 1 first would break the authentication needed for Part 2 cleanup.

## 🚧 Troubleshooting

### Common Issues

**Authentication Errors (Part 1)**
- Verify AWS IAM authentication is properly configured in Akeyless
- Check that `aws_iam_access_id` matches your Akeyless auth method
- Ensure AWS credentials have sufficient permissions

**Permission Errors (Part 2)**
- Verify the role created in Part 1 has proper access rules
- Check that API Key was generated from the correct auth method
- Ensure the role has read access to the static secret paths

**AWS Credential Issues**
- Verify AWS credentials have proper DynamoDB permissions
- Check that terraform.tfvars contains valid AWS credentials
- Ensure the AWS region is correctly configured

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