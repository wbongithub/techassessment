variable "primary_region" {
  description = "Primary region to deploy to"
  type        = string
}

variable "disaster_recovery_region" {
  description = "Disaster Recovery region to deploy to"
  type        = string
}

variable "cron_schedule" {
  description = "The AWS Cron notation for the backup schedule"
  type        = string
  default     = "cron(0 12 * * ? *)"
}