# Variables for Part 2: Infrastructure Deployment (Complete Version)

variable "akeyless_gateway_address" {
  description = "Akeyless API Gateway address"
  type        = string
  default     = "https://api.akeyless.io"
}

variable "akeyless_access_id" {
  description = "Akeyless Access ID for API key authentication"
  type        = string
  sensitive   = true
}

variable "akeyless_access_key" {
  description = "Akeyless Access Key for API key authentication"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for infrastructure deployment"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for infrastructure deployment"
  type        = string
  sensitive   = true
}