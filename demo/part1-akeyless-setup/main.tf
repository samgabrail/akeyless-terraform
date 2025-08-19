# Part 1: Akeyless Configuration Demo (Simplified)
# This demonstrates Akeyless setup without AWS dependencies

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

# Configure Akeyless provider using API key authentication
provider "akeyless" {
  api_gateway_address = var.akeyless_gateway_address
  api_key_login {
    access_id  = var.akeyless_access_id
    access_key = var.akeyless_access_key
  }
}

# Generate random suffix for unique naming
resource "random_password" "api_suffix" {
  length  = 8
  special = false
  upper   = false
}

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

# Create static secret (external API key example)
resource "akeyless_static_secret" "external_api_key" {
  path  = "/terraform-demo/static/api-key"
  value = "external-service-api-key-${random_password.api_suffix.result}"
}

# Generate a secure database password
resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Create static secret for database password
resource "akeyless_static_secret" "db_password" {
  path  = "/terraform-demo/static/db-password"
  value = random_password.db_password.result
}

# Create static secret for database configuration
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