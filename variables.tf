variable "organization" {
  type        = "string"
  description = "TFE Organization"
}

variable "db_workspace" {
  type        = "string"
  description = "DB Workspace"
}

variable "vault_token" {}

variable "vault_cluster" {}

variable "db_host" {}

variable "client_addr" {}
