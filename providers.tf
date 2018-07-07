provider "azurerm" {}

provider "vault" {
  address = "http://${var.vault_cluster}:8200"
  token   = "${var.vault_token}"
}

provider "mysql" {
  endpoint = "${data.terraform_remote_state.db.fqdn}:3306"
  username = "${data.vault_generic_secret.db_credentials.data["username"]}"
  password = "${data.vault_generic_secret.db_credentials.data["password"]}"
}
