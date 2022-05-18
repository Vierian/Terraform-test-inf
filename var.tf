variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "terraform-test"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "domain" {
  description = "Domain for site"
  default     = "example.com"
  type        = string
}