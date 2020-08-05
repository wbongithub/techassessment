resource "random_pet" "this" {
  length = 2
}

resource "aws_backup_plan" "this" {
  name = "backup-plan-${random_pet.this.id}"

  rule {
    recovery_point_tags = {
      "Environment" = "production"
    }
    rule_name         = "rule-1-${random_pet.this.id}"
    schedule          = var.cron_schedule
    start_window      = 60
    completion_window = 360
    target_vault_name = aws_backup_vault.this.name

    copy_action {
      destination_vault_arn = aws_backup_vault.that.arn

      lifecycle {
        cold_storage_after = 0
        delete_after       = 1095
      }
    }

    lifecycle {
      cold_storage_after = 0
      delete_after       = 1095
    }
  }
  tags = merge(local.common_tags,
    {
      "Component" = "AWS Backup",
    }
  )
}

resource "aws_backup_selection" "this" {
  iam_role_arn = aws_iam_role.this.arn
  name         = "backup-selection-${random_pet.this.id}"
  plan_id      = aws_backup_plan.this.id

  resources = [
    data.terraform_remote_state.core.outputs.db,
  ]

}

resource "aws_backup_vault" "this" {
  provider = aws.primary
  name     = "backup-primary-vault-${random_pet.this.id}"
  tags = merge(local.common_tags,
    {
      "Component" = "AWS Backup",
    }
  )
}

resource "aws_backup_vault" "that" {
  provider = aws.secondary
  name     = "backup-secondary-${random_pet.this.id}"
  tags = merge(local.common_tags,
    {
      "Component" = "AWS Backup",
    }
  )
}