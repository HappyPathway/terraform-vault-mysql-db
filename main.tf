data "vault_generic_secret" "db_credentials" {
  path = "secret/database/${data.terraform_remote_state.db.server_name}/${data.terraform_remote_state.db.db_name}/credentials"
}

resource "vault_mount" "db" {
  path = "db-${data.terraform_remote_state.db.server_name}"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = "${vault_mount.db.path}"
  name          = "mysql"
  allowed_roles = ["dev", "prod"]

  mysql {
    connection_url = "mysql://${data.vault_generic_secret.db_credentials.data["username"]}:${data.vault_generic_secret.db_credentials.data["password"]}@${var.db_host}:3306/${data.terraform_remote_state.db.db_name}"
  }
}

resource "vault_database_secret_backend_role" "mysql_admin" {
  backend             = "${vault_mount.db.path}"
  name                = "mysql_admin"
  db_name             = "${vault_database_secret_backend_connection.mysql.name}"
  creation_statements = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; grant all on *.* to '{{name}}'@'%'"
}

resource "vault_database_secret_backend_role" "mysql_ro" {
  backend             = "${vault_mount.db.path}"
  name                = "mysql_ro"
  db_name             = "${vault_database_secret_backend_connection.mysql.name}"
  creation_statements = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; grant SELECT on *.* to '{{name}}'@'%'"
}

# CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';

