# Akeyless + Terraform: Managing Secrets in Cloud Infrastructure

## Introduction

If you're a Terraform user, you've likely heard of, or are already using, HashiCorp Vault for managing secrets. But what if there was a more cloud-native, operationally simpler way to achieve powerful secrets management directly in your Terraform configuration? This blog post demonstrates that Akeyless isn't just an alternative to traditional secret management tools; it's a better fit for modern infrastructure as code workflows.

We'll prove it by showing how to securely store secrets, manage sensitive information, and protect against data breaches using secrets that flow seamlessly through your cloud infrastructure without complex backend configuration or clustering requirements.

## Video Demo

https://share.descript.com/view/EO8k4lohyrB

## Code Repo

Here is the code on GitHub for this post.

## Target Audience

- **Platform Engineers** managing cloud resources and Terraform code
- **Security Engineers** focused on secrets management and access control
- **Terraform Users** currently using HashiCorp Vault or AWS Secrets Manager
- **Organizations** seeking advanced secret management tools with role based access control
- **Teams** looking to encrypt sensitive data and prevent security breaches

## Key Points: Why Akeyless Outperforms Traditional Secret Management Tools

### Managing Secrets with Zero-Trust Architecture vs HashiCorp Vault

- **Zero-Trust Architecture**: Akeyless provides secrets management without storing complete secrets, unlike traditional solutions
- **Cloud-Native Design**: Purpose-built for modern cloud resources and environment variables management
- **Simplified Operations**: No complex infrastructure to manage compared to HashiCorp Vault clustering requirements, for more details, check my blog post called A HashiCorp Vault Alternative: How Akeyless Simplifies Your Security and Cuts Costs
- **Enhanced Security**: Distributed fragments approach eliminates single points of failure and security breaches
- **Infrastructure as Code Support**: Native Terraform integration with role based access control and secret rotation capabilities. Check the Akeyless Terraform provider

## Two Integration Parts

### Part 1: Managing Akeyless as Code

**Use Case**: Using infrastructure as code to configure your secret management tools

**What We'll Demonstrate with Terraform Configuration:**

- Configure authentication methods with role based access control using the Akeyless Terraform Provider
- Create and manage static secrets including API keys and database credentials
- Implement access control policies with least privilege principle
- Store configuration data as key value pairs for infrastructure deployment

## Demo Scenario Part 1: Terraform Configuration for Managing Secrets Infrastructure

Setting up the foundation with proper terraform configuration and handling secrets securely:

### Step 1: Provider Configuration Block

First, we configure the required providers for managing secrets with infrastructure as code:

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    akeyless = {
      source  = "akeyless-community/akeyless"
      version = ">= 1.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
```

The terraform config block establishes version requirements ensuring compatibility with advanced features for managing sensitive data.

### Step 2: Secure Provider Authentication

Next, we configure the Akeyless provider without hardcoding sensitive values in code repositories:

```hcl
provider "akeyless" {
  api_gateway_address = var.akeyless_gateway_address
  api_key_login {
    access_id  = var.akeyless_access_id
    access_key = var.akeyless_access_key
  }
}
```

This configuration block uses environment variables or a terraform.tfvars file that is not pushed to GitHub and is part of the .gitignore file. The purpose here is to handle secrets authentication, preventing secrets stored in version control systems.

### Step 3: Role Based Access Control Implementation

Now we establish secure access control for managing secrets:

```hcl
# Create API Key authentication method
resource "akeyless_auth_method_api_key" "terraform_auth" {
  name = "/terraform-demo/auth-method"
}

# Create access role
resource "akeyless_role" "terraform_role" {
  name = "/terraform-demo/role"
  
  rules {
    capability = ["read", "list"]
    path       = "/terraform-demo/static/*"
    rule_type  = "item-rule"
  }
}

# Associate the access role with the auth method
resource "akeyless_associate_role_auth_method" "terraform_auth_association" {
  am_name   = akeyless_auth_method_api_key.terraform_auth.name
  role_name = akeyless_role.terraform_role.name
}
```

This implements both an authentication method using an API key in Akeyless along with an access role. This combination creates a role based access control (RBAC) setup, ensuring only authorized terraform code can access secrets for part 2 of our demo.

Notice that the access role contains a rule for readling and listing the secrets we will create in the next step at a certain path. This applies the least privilege principle to ensure only authorized access to our secrets. 

In short, the holder of the api key associated with the auth method will only have read and list acess to secrets at the path: `/terraform-demo/static/*`

### Step 4: Secure Database Credentials Creation

Here we generate and store database credentials using best practices for handling secrets:

```hcl
resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "akeyless_static_secret" "db_password" {
  path  = "/terraform-demo/static/db-password"
  value = random_password.db_password.result
}
```

This approach generates secure passwords that include uppercase letters, lowercase letters, and special characters while storing secrets in Akeyless for later retrieval in part 2.

### Step 5: API Keys and Configuration Management

Finally, we create additional secrets including API keys and configuration data using key value pairs:

```hcl
resource "akeyless_static_secret" "db_config" {
  path = "/terraform-demo/static/db-config"
  value = jsonencode({
    table_name = "terraform-demo-table"
    hash_key   = "id"
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    billing_mode = "PAY_PER_REQUEST"
    tags = {
      Environment = "Demo"
      CreatedBy   = "Terraform"
      SecretSource = "Akeyless"
    }
  })
}

resource "random_password" "api_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "akeyless_static_secret" "external_api_key" {
  path  = "/terraform-demo/static/api-key"
  value = "external-service-api-key-${random_password.api_suffix.result}"
}
```

This demonstrates storing sensitive values including API keys and complex configuration as JSON, ensuring sensitive information remains protected.

## Transition: Credential Reset for Security

**Critical Step**: Between Part 1 and Part 2, we reset the access key for the newly created authentication method. This ensures that the credentials used for infrastructure deployment in Part 2 are never stored in Terraform's state file from Part 1, following security best practices for separating setup credentials from runtime access credentials.

### Part 2: Using Akeyless Secrets to Build Infrastructure

**Use Case**: Leveraging secret management tools for secure cloud services deployment

**What We'll Demonstrate for Secret Management:**

- Reading secrets from Akeyless during terraform apply
- Using retrieved secret values and configuration data to provision cloud infrastructure

## Demo Scenario Part 2: Terraform Secrets Retrieval and AWS Infrastructure Deployment

This section demonstrates how to read secrets from your secret management tools and use them with cloud resources.

### Step 1: Multi-Provider Configuration for Cloud Infrastructure

We configure both the AWS provider and Akeyless for managing cloud resources:

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    akeyless = {
      source  = "akeyless-community/akeyless"
      version = ">= 1.10.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "akeyless" {
  api_gateway_address = var.akeyless_gateway_address
  api_key_login {
    access_id  = var.akeyless_access_id
    access_key = var.akeyless_access_key
  }
}
```

This multi-cloud setup allows us to handle secrets while deploying to AWS, avoiding hardcoded values in our terraform code.

### Step 2: Retrieving Secret Values at Runtime

Here we demonstrate how to read secrets using the data blocks:

```hcl
data "akeyless_secret" "external_api_key" {
  path = "/terraform-demo/static/api-key"
}

data "akeyless_secret" "db_password" {
  path = "/terraform-demo/static/db-password"
}

data "akeyless_secret" "db_config" {
  path = "/terraform-demo/static/db-config"
}
```

These data sources retrieve secret values at runtime, ensuring sensitive information is never hardcoded in code repositories.

### Step 3: Processing Retrieved Secret Values and AWS Provider Configuration

We parse the retrieved configuration and set up our cloud provider authentication using environment variables:

```hcl
locals {
  db_config = jsondecode(data.akeyless_secret.db_config.value)
  api_key_masked = "${substr(data.akeyless_secret.external_api_key.value, 0, 10)}..."
  db_password_masked = "${substr(data.akeyless_secret.db_password.value, 0, 4)}****"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
```

The local values allow us to work with complex secret data and manipulate the data to the format we desire. 

The AWS provider uses separate variables for cloud authentication which we feed via a terraform.tfvars file similar to the one we provided in part 1. This file is also not pushed into GitHub. You could also feed the AWS credentials via environment variables if you choose to.

### Step 4: AWS Infrastructure Deployment Using Retrieved Secrets

Now we deploy cloud resources using the configuration and credentials retrieved from Akeyless:

```hcl
resource "aws_dynamodb_table" "demo_table" {
  name         = local.db_config.table_name
  billing_mode = local.db_config.billing_mode
  hash_key     = local.db_config.hash_key

  dynamic "attribute" {
    for_each = local.db_config.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  tags = merge(
    local.db_config.tags,
    {
      ExternalAPIKey = local.api_key_masked
      SecretSource   = "Akeyless"
      PasswordSource = "Retrieved from Akeyless"
    }
  )
}
```

This demonstrates deploying an AWS dynamo DB resource while keeping all sensitive information securely managed outside of our terraform code. However, care must be taken as these secrets will appear in the Terraform state file. This state file needs to be encrypted at rest and with restricted access.

### Step 5: Database Population with Audit Trail

Finally, we populate the database with sample data that demonstrates our secure secrets workflow:

```hcl
resource "aws_dynamodb_table_item" "demo_items" {
  count      = 3
  table_name = aws_dynamodb_table.demo_table.name
  hash_key   = aws_dynamodb_table.demo_table.hash_key

  item = jsonencode({
    id = {
      S = "demo-item-${count.index + 1}"
    }
    timestamp = {
      N = tostring(1672531200 + count.index)
    }
    message = {
      S = "Demo item ${count.index + 1} created using credentials retrieved from Akeyless"
    }
    api_key_source = {
      S = "Retrieved from ${data.akeyless_secret.external_api_key.path}"
    }
    db_credential_source = {
      S = "Retrieved from ${data.akeyless_secret.db_password.path}"
    }
    security_note = {
      S = "All credentials fetched at runtime, zero secrets exposure in configuration"
    }
  })
}
```

This creates database items with full audit trails showing how secret values were retrieved, demonstrating complete transparency in our secrets management workflow.

### Step 6: Secure Output Values

The final step provides outputs while maintaining security best practices:

```hcl
output "dynamodb_table_name" {
  value     = aws_dynamodb_table.demo_table.name
  sensitive = true
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.demo_table.arn
}

output "demo_items_count" {
  value = length(aws_dynamodb_table_item.demo_items)
}

output "secrets_used" {
  value = {
    external_api_key = data.akeyless_secret.external_api_key.path
    database_config  = data.akeyless_secret.db_config.path
    database_password = data.akeyless_secret.db_password.path
  }
  sensitive = true
}
```

Notice how outputs containing sensitive values are marked appropriately, ensuring the state file handles secrets securely while providing visibility into which secret paths were used. Again remember that access to the state file needs to be restricted. Which leads me to make the disclaimer below more vivid.

**Important Security Note for State File Management**: While this demo shows how to retrieve secret values in Terraform, be aware that retrieved secrets are stored in the terraform state file. Always ensure your state files are properly secured with encryption at rest and access control, preventing data breaches from exposed state files. Consider using backend configuration with encryption keys and AWS KMS key integration for additional protection if you choose to use an AWS S3 bucket for your Terraform backend.

**Future Security Enhancements**: Terraform 1.10+ introduces ephemeral resources and 1.11+ adds write-only attributes that eliminate secrets from state files entirely. While the Akeyless provider doesn't yet support these advanced features, they represent the future of secure terraform secrets management where sensitive values never persist in state, providing better protection than traditional secrets manager defaults.

## Demo Cleanup: Best Practices for Infrastructure Destruction

After completing both parts of the demonstration, proper cleanup follows a specific order to prevent authentication failures and dependency issues:

### Critical Cleanup Order for Terraform Secrets Management

#### Step 1: Destroy Part 2 Infrastructure First

```bash
cd part2-infrastructure-deployment
terraform destroy
```

This removes the AWS cloud resources (DynamoDB table and sample data) that depend on credentials and secrets from Part 1.

#### Step 2: Destroy Part 1 Infrastructure Second

```bash
cd ../part1-akeyless-setup
terraform destroy
```

This removes the Akeyless secrets management infrastructure including authentication methods, static secrets, and access control policies.

### Why This Order Matters for Managing Secrets

Part 2 uses credentials and accesses secrets created in Part 1. If you destroy Part 1 first, the authentication needed for Part 2 cleanup will fail, leaving orphaned cloud resources. This demonstrates the dependency relationship between secrets management infrastructure and the applications that consume those secrets - a key consideration when managing sensitive data in production environments.

This cleanup order reflects real-world best practices: always destroy consuming services before destroying the secret management tools and configuration data they depend on, ensuring complete infrastructure as code lifecycle management.

## Getting Started with Terraform Secrets Management Using Akeyless

Ready to transform your infrastructure secrets management and prevent security breaches? Here's your path forward:

### 1. Try the Infrastructure as Code Demo

Clone our complete working example from GitHub, mentioned at the top of this post, and run it in your own environment. The two-part demo takes less than 15 minutes to complete and demonstrates the full terraform configuration integration with secure secret values handling.

### 2. Start Your Free Trial

Get started with Akeyless for free at this link: [Akeyless Security: Register](https://www.akeyless.io/signup/).

### 3. Migration Support from HashiCorp Vault and AWS Secrets Manager

Akeyless' solutions architects provide help to plan your migration from existing secret management tools.

## Frequently Asked Questions (FAQ)

### What is Akeyless and how does it work with Terraform Secrets Management?

Akeyless is a zero-trust secret management tool that integrates natively with terraform configuration through a comprehensive AWS provider. Unlike traditional solutions like AWS Secrets Manager, Akeyless uses fragment-based architecture where secret values never exist in complete form anywhere, providing superior security for your infrastructure as code automation while managing sensitive data across cloud resources. Check out Akeyless' Innovative DFC Technology.

### How is Akeyless different from HashiCorp Vault for Managing Secrets with Terraform?

Akeyless offers several key advantages over traditional vault provider solutions: SaaS-first with no complex backend configuration to manage, fragment-based security model that prevents data breaches, native cloud services integrations, and a purpose-built terraform provider with 30+ resources for complete infrastructure as code support. While HashiCorp Vault requires complex clustering and operational overhead for securely storing secrets, Akeyless provides enterprise-grade secrets management with minimal maintenance and superior access control capabilities. Check out my comparison blog with Vault.

### How to Handle Secrets in Terraform State File without Data Leakage?

While current terraform configuration versions store retrieved secret values in the state file, you can minimize exposure through proper state encryption and access control policies. Use backend configuration with encryption keys, AWS KMS key integration, and secure state file storage to prevent data breaches. Terraform 1.10+ introduces ephemeral resources and 1.11+ adds write-only attributes that will eliminate secrets from state entirely. These are advanced features we're working to support in future provider releases for managing sensitive information without state file exposure.

### What Types of Secret Values Can Akeyless Manage for Infrastructure as Code?

Akeyless supports comprehensive secrets management including static secrets (API keys, database credentials, certificates), and configuration data in key value pairs format, as demonstrated in our terraform code examples. You can manage database credentials, SSH keys, encryption keys, TLS certificates, and environment variables for cloud services deployment. While Akeyless also supports dynamic secrets for advanced use cases, our demo focuses on the most common pattern: static secrets for database passwords, API keys, and configuration data that flows securely through your terraform configuration.

### Does Akeyless Support Multi-Cloud Infrastructure as Code Deployments?

Absolutely. Akeyless is built for multi-cloud environments with native integrations for AWS, Azure Key Vault, GCP, and Kubernetes cloud services. You can manage sensitive data consistently across all cloud provider platforms through a single interface and terraform provider, eliminating the need for separate secret management tools for each cloud service while maintaining consistent environment variables and API keys management.

### How Does Akeyless Handle Secret Rotation Management?

Akeyless provides automatic secret rotation for dynamic secrets including cloud provider credentials and database username authentication, plus configurable rotation policies for static secrets like API keys and encryption keys. 

### How Does Akeyless Ensure High Availability and Prevent Data Breaches?

The SaaS platform provides built-in high availability across multiple regions with automatic failover capabilities. For on-premises deployments, gateways can be clustered for redundancy without the complex backend configuration required by HashiCorp Vault. The fragment-based architecture ensures that no single component failure can compromise your secrets secure storage, providing superior protection against security breaches compared to traditional vault secrets solutions that have single points of failure.