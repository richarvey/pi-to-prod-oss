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

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private-"
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public-"
}

variable "database_subnet_suffix" {
  description = "Suffix to append to database subnets name"
  type        = string
  default     = "rds-"
}

variable "additional_tags" {
  description = "Additional default resource tags"
  type        = map(string)
  default     = {}
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}