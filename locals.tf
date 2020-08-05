locals {
  common_tags = {
    TerraformProject = reverse(split("/", path.cwd))[0]
    Organization     = "EwoksLLC"
    Region           = var.region
  }
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.django_preseed_config.secret_string
  )
}

locals {
  ecr_name = "example-ecr-repo"
}

locals {
  container_name = "example-app"
}