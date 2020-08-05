# Terraform and AWS Backup

These resources set up AWS Backup with Vaults in 2 regions, a Backup Plan and a Backup Selection (the RDS database).

After applying the resources from the core project (the parent directory), run `terraform apply -var="primary_region=eu-central-1" -var="disaster_recovery_region=eu-west-2"` in this directory to apply the AWS Backup resources, and set up automated snapshot replication between the primary and disaster recovery region.

## Local or Remote State

Currently, a data.terraform_remote_state source is set up, which points to the `terraform.tfstate` in the parent directory.

To use a remote state, move `data_local_state.tf` to `data_local_state.tf.disabled`, then move `data_remote_state.tf.disabled` to `data_remote_state.tf`, configure the right bucket, key and region.

Next, run `terraform init` to fetch the remote state, followed by a `terraform apply`.

## Terraform Destroy

AWS Backup Vaults Plans/Selections don't seem to respond to terraform changes, so to change them, taint them:

```
terraform taint aws_backup_plan.this
```

During a terraform destroy, the AWS Backup Vault resources might 'stick' as
well, so run a short script:
```
#!/bin/sh
targets=""
for i in $(terraform state list | grep -v "state"); do targets="${targets} --target=${i}"; done
terraform destroy ${targets}
terraform destroy
```
