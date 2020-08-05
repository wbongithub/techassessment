// Manually create this secret first !
// aws secretsmanager create-secret --name DjangoPreseedConfig --description "Django Preseed Configuration" \
// --secret-string file://db_preseed.json
data "aws_secretsmanager_secret_version" "django_preseed_config" {
  secret_id = var.django_secret
}

resource "aws_secretsmanager_secret" "this" {
  name = "django_config-${random_pet.this.id}"
  tags = merge(local.common_tags,
    {
      "Component" = "SecretsManager",
    }
  )
}

resource "aws_secretsmanager_secret_version" "django_config" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(
    {
      "django_secret_key" : jsondecode(data.aws_secretsmanager_secret_version.django_preseed_config.secret_string)["django_secret_key"]
      "django_admin_user" : jsondecode(data.aws_secretsmanager_secret_version.django_preseed_config.secret_string)["django_admin_user"]
      "django_admin_password" : jsondecode(data.aws_secretsmanager_secret_version.django_preseed_config.secret_string)["django_admin_password"]
      "django_admin_mail" : jsondecode(data.aws_secretsmanager_secret_version.django_preseed_config.secret_string)["django_admin_mail"]
      "db_username" : jsondecode(data.aws_secretsmanager_secret_version.django_preseed_config.secret_string)["db_username"],
      "db_password" : jsondecode(data.aws_secretsmanager_secret_version.django_preseed_config.secret_string)["db_password"],
      "db_host" : aws_db_instance.this.endpoint,
      "db_dbname" : aws_db_instance.this.name,
      "cache_host" : aws_elasticache_cluster.this.configuration_endpoint
    }
  )

}