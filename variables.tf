variable "create" {
  description = "Whether to create all resources"
  type        = bool
}

variable "env" {
  description = "The environment where the infrastructure is setting up"
  type        = string
}

variable "db_secret_user" {
  type      = string
  sensitive = true
}

variable "db_secret_pass" {
  type      = string
  sensitive = true
}
