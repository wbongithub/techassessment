## BACKUP IAM

data "aws_iam_policy_document" "assume_by_backup" {
  statement {
    sid     = "AllowAssumeByBackup"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "backup-role-${random_pet.this.id}"
  assume_role_policy = data.aws_iam_policy_document.assume_by_backup.json
  //  tags               = merge(local.common_tags, {})

}

data "aws_iam_policy_document" "backup_tags" {
  statement {
    sid    = "AllowBackupTag"
    effect = "Allow"

    actions = [
      "backup:TagResource",
      "backup:ListTags",
      "backup:UntagResource",
      "tag:GetResources",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.backup_tags.json
}

data "aws_iam_policy" "backup_create" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "backup_restore" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy_attachment" "backup_policy_attach" {
  policy_arn = data.aws_iam_policy.backup_create.arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "restore_policy_attach" {
  policy_arn = data.aws_iam_policy.backup_restore.arn
  role       = aws_iam_role.this.name
}

# Backup IAM Role Outputs
output "iam_aws_backup_role_arn" {
  value = aws_iam_role.this.arn
}

output "iam_aws_backup_role_id" {
  value = aws_iam_role.this.id
}

output "iam_aws_backup_role_name" {
  value = aws_iam_role.this.name
}