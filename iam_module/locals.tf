locals {
  common_tags = {
    TerraformModule = reverse(split("/", path.cwd))[0]
    Region          = var.region
  }
}