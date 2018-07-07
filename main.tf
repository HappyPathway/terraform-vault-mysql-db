data "template_file" "credentials" {
  template = "${file("${path.module}/vault_credentials.json.tpl")}"

  vars {
    username = "${random_string.username.result}"
    password = "${random_string.password.result}"
  }
}

resource "vault_generic_secret" "credentials" {
  path      = "secret/database/${var.server_name}/${var.db_name}/credentials"
  data_json = "${data.template_file.credentials.rendered}"
}

resource "vault_mount" "db" {
  path = "db-${var.server_name}"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = "${vault_mount.db.path}"
  name          = "mysql"
  allowed_roles = ["dev", "prod"]

  depends_on = [
    "azurerm_mysql_server.server",
  ]

  mysql {
    connection_url = "mysql://${random_string.username.result}:${random_string.password.result}@${azurerm_mysql_server.server.fqdn}:3306/${var.db_name}"
  }
}

