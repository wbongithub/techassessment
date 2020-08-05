locals {
  common_tags = {
    TerraformModule        = reverse(split("/", path.cwd))[0]
    PrimaryRegion          = var.primary_region
    DisasterRecoveryRegion = var.disaster_recovery_region
  }
}