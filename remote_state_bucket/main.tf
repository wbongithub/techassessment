variable "region" {}

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    TerraformModule = reverse(split("/", path.cwd))[0]
  }
}

resource "random_pet" "this" {
  length = 2
}

# Use terraform registry module for setting up remote private state
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-state-${random_pet.this.id}"
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = merge(local.common_tags,
    {
      "Component" = "RemoteState",
    }
  )

}

output "s3_bucket_id" {
  value = module.s3_bucket.this_s3_bucket_id
}

# Create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "this" {
  name           = "terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = merge(local.common_tags,
    {
      "Component" = "RemoteState",
    }
  )
}

output "aws_dynamodb_table_table" {
  value = aws_dynamodb_table.this.name
}