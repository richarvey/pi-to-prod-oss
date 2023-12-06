variable "name" {
  description = "Solution name"
  type        = string
  default     = "simple-vpc"
}

variable "environment" {
  description = "Execution environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the solution"
  type        = string
  default     = "sqcows"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable additional_tags {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}