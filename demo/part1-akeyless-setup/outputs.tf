# Outputs for Part 1: Akeyless Setup

output "auth_method_name" {
  description = "Name of the created authentication method"
  value       = akeyless_auth_method_api_key.terraform_auth.name
}

output "role_name" {
  description = "Name of the created role"
  value       = akeyless_role.terraform_role.name
}

output "static_secret_paths" {
  description = "Paths to created static secrets"
  value = {
    api_key     = akeyless_static_secret.external_api_key.path
    db_password = akeyless_static_secret.db_password.path
    db_config   = akeyless_static_secret.db_config.path
  }
}

output "database_password_path" {
  description = "Path to the database password in Akeyless"
  value       = akeyless_static_secret.db_password.path
}

output "database_config_path" {
  description = "Path to the database configuration in Akeyless"
  value       = akeyless_static_secret.db_config.path
}

output "setup_summary" {
  description = "Summary of created Akeyless infrastructure"
  value = {
    authentication_method = akeyless_auth_method_api_key.terraform_auth.name
    role                 = akeyless_role.terraform_role.name
    static_secrets_count = 3
    database_password    = akeyless_static_secret.db_password.path
    database_config     = akeyless_static_secret.db_config.path
    note                = "Database secrets ready for Part 2 infrastructure deployment"
  }
}