# Variables for Part 1: Akeyless Setup (Full Version)

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

