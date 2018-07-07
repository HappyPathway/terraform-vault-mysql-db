provider "azurerm" {}

provider "vault" {
  address = "http://${data.vault_generic_secret.db_credentials.vault_cluster}:8200"
  token   = "${data.vault_generic_secret.db_credentials.vault_token}"
}
