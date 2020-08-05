variable "github_owner" {
  description = "The GitHub Repository Owner to be used for the CodePipeline"
  type        = string
}

variable "github_repo" {
  description = "The GitHub Repository to be used for the CodePipeline"
  type        = string
}

variable "github_branch" {
  description = "The GitHub Repository Branch to be used for the CodePipeline"
  type        = string
  default     = "master"
}

// https://github.com/terraform-providers/terraform-provider-aws/issues/6646#issue-385850869 -> fixed in aws provider 3.0!
variable "github_token" {
  description = "The GitHub Token to be used for the CodePipeline"
  type        = string
}

variable "account_id" {
  description = "id of the active account"
  type        = string
}

variable "region" {
  description = "region to deploy to"
  type        = string
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "enable_restore" {
  type    = bool
  default = false
}

variable "db_snapshot_identifier" {
  type    = string
  default = ""
}

variable "django_secret" {
  default = "DjangoPreseedConfig"
}

variable "enable_rds_multi_az" {
  type    = bool
  default = false
}
