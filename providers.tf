provider "azurerm" {}

provider "vault" {
  address = "http://${var.vault_cluster}:8200"
  token   = "${var.vault_token}"
}
