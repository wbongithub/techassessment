# Terraform Remote State

These resources set up a S3 bucket, with versioning enabled, and a DynamoDB Table for locking the terraform state.

If you wish to configure a remote state for the core project (which is currently using a local state file), make sure to run `terraform apply` in this directory first.

Next, move the `remote_state.tf.disabled` file in the parent directory to `remote_state.tf`, and configure the right bucket, key and region, based on the output of running `terraform apply` in this directory.
