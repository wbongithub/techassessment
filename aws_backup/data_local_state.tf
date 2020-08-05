data "terraform_remote_state" "core" {
  backend = "local"
  config = {
    path = "${path.module}/../terraform.tfstate.d/eu-central-1/terraform.tfstate"
  }
}
