# Part 2: Database Infrastructure Deployment
# This demonstrates retrieving database secrets from Akeyless and using them to deploy AWS DynamoDB

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

# Configure Akeyless provider for secret retrieval
provider "akeyless" {
  api_gateway_address = var.akeyless_gateway_address
  api_key_login {
    access_id  = var.akeyless_access_id
    access_key = var.akeyless_access_key
  }
}

# Retrieve database secrets from Akeyless
data "akeyless_secret" "external_api_key" {
  path = "/terraform-demo/static/api-key"
}

data "akeyless_secret" "db_password" {
  path = "/terraform-demo/static/db-password"
}

data "akeyless_secret" "db_config" {
  path = "/terraform-demo/static/db-config"
}

# Parse the database configuration JSON retrieved from Akeyless
locals {
  db_config = jsondecode(data.akeyless_secret.db_config.value)
  api_key_masked = "${substr(data.akeyless_secret.external_api_key.value, 0, 10)}..."
  db_password_masked = "${substr(data.akeyless_secret.db_password.value, 0, 4)}****"
}

# Configure AWS provider using variables
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Create DynamoDB table using configuration retrieved from Akeyless
resource "aws_dynamodb_table" "demo_table" {
  name           = local.db_config.table_name
  billing_mode   = local.db_config.billing_mode
  hash_key       = local.db_config.hash_key

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
      ExternalAPIKey   = local.api_key_masked
      SecretSource     = "Akeyless"
      CreatedAt        = timestamp()
      PasswordSource   = "Retrieved from Akeyless"
    }
  )
}

# Add sample data to the table to demonstrate the database is working
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
      S = "All credentials fetched at runtime - zero secrets exposure in configuration"
    }
  })
}