variable "name" {
  description = "Solution name"
  type        = string
  default     = "sqcows-ops-mgmt"
}

variable "owner" {
  description = "Owner of the solution"
  type        = string
  default     = "sqcows"
}

variable "environment" {
  description = "Execution environment"
  type        = string
  default     = "development"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "additional_tags" {
  description = "Additional default resource tags"
  type        = map(string)
  default     = {}
}