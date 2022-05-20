variable "namespace" {
  description = "The project namespace to use for unique resource naming and tagging"
  default     = "terraform-osm-aed"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
  type        = string
}

variable "domain" {
  description = "Domain for site"
  default     = "example.com"
  type        = string
}

variable "repository"{
  description = "Github repository to clone"
  default     = "openstreetmap-polska/aed-mapa"
  type        = string
}