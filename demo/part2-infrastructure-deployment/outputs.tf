# Outputs for Part 2: Database Infrastructure Deployment

output "dynamodb_table_name" {
  description = "Name of the created DynamoDB table"
  value       = aws_dynamodb_table.demo_table.name
  sensitive   = true
}

output "dynamodb_table_arn" {
  description = "ARN of the created DynamoDB table"
  value       = aws_dynamodb_table.demo_table.arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.demo_table.id
}

output "demo_items_count" {
  description = "Number of demo items created in the table"
  value       = length(aws_dynamodb_table_item.demo_items)
}

output "secrets_used" {
  description = "Information about secrets retrieved from Akeyless"
  value = {
    external_api_key_preview = local.api_key_masked
    database_password_preview = local.db_password_masked
    table_name               = local.db_config.table_name
    billing_mode             = local.db_config.billing_mode
    hash_key                 = local.db_config.hash_key
  }
  sensitive = true
}

output "database_resources_created" {
  description = "Summary of database resources created using Akeyless secrets"
  value = {
    dynamodb_table      = aws_dynamodb_table.demo_table.name
    billing_mode        = aws_dynamodb_table.demo_table.billing_mode
    hash_key           = aws_dynamodb_table.demo_table.hash_key
    demo_items_created = length(aws_dynamodb_table_item.demo_items)
    tags_applied       = "Yes - including secret metadata"
    secret_sources     = "Database password and configuration from Akeyless"
  }
  sensitive = true
}

output "demo_success" {
  description = "Complete demo status"
  value = {
    part_1_akeyless_setup     = "✅ Completed - Auth methods, roles, and database secrets created"
    part_2_secret_retrieval   = "✅ Completed - Database secrets retrieved from Akeyless"
    part_3_database_deployment = "✅ Completed - DynamoDB table created with retrieved secrets"
    integration_status        = "✅ Full Akeyless + Terraform + AWS Database integration working!"
    security_demonstration    = "✅ Database password used without exposure in configuration"
  }
}