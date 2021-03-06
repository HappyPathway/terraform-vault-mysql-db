data "vault_generic_secret" "db_credentials" {
  path = "secret/database/${data.terraform_remote_state.db.server_name}/${data.terraform_remote_state.db.db_name}/credentials"
}

resource "vault_mount" "db" {
  path = "db-${data.terraform_remote_state.db.server_name}"
  type = "database"
}

data "template_file" "vault_backend_connection" {
  template = "${file("${path.module}/database_connection.json.tpl")}"

  vars = {
    db_host        = "${data.terraform_remote_state.db.fqdn}"
    db_port        = 3306
    db_name        = "${data.terraform_remote_state.db.db_name}"
    username       = "${data.vault_generic_secret.db_credentials.data["username"]}"
    password       = "${data.vault_generic_secret.db_credentials.data["password"]}"
    db_server_name = "${data.terraform_remote_state.db.server_name}"
  }
}

#resource "vault_generic_secret" "MySQLConnection" {
#  path      = "db-${data.terraform_remote_state.db.server_name}/config/${data.terraform_remote_state.db.db_name}"
#  data_json = "${data.template_file.vault_backend_connection.rendered}"
#}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = "${vault_mount.db.path}"
  name          = "${data.terraform_remote_state.db.db_name}"
  allowed_roles = ["mysql_admin", "mysql_ro"]

  mysql {
    connection_url = "${data.vault_generic_secret.db_credentials.data["username"]}@${data.terraform_remote_state.db.server_name}:${data.vault_generic_secret.db_credentials.data["password"]}@tcp(${data.terraform_remote_state.db.fqdn}:3306)/${data.terraform_remote_state.db.db_name}"
  }
}

resource "vault_database_secret_backend_role" "mysql_admin" {
  backend             = "${vault_mount.db.path}"
  name                = "mysql_crud"
  db_name             = "${data.terraform_remote_state.db.db_name}"
  creation_statements = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; grant SELECT,INSERT,UPDATE,DELETE on ${data.terraform_remote_state.db.db_name}.* to '{{name}}'@'%'"
}

resource "vault_database_secret_backend_role" "mysql_ro" {
  backend             = "${vault_mount.db.path}"
  name                = "mysql_ro"
  db_name             = "${data.terraform_remote_state.db.db_name}"
  creation_statements = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; grant SELECT on ${data.terraform_remote_state.db.db_name}.* to '{{name}}'@'%'"
}

# CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';

