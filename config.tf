data "terraform_remote_state" "db" {
  backend = "atlas"

  config {
    name = "${var.organization}/${var.db_workspace}"
  }
}
