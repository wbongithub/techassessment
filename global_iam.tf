module "global_iam" {
  source                    = "./iam_module"
  region                    = var.region
  codebuild_project_arn     = aws_codebuild_project.this.arn
  ecr_repository_arn        = aws_ecr_repository.this.arn
  ecs_cluster_arn           = aws_ecs_cluster.this.arn
  s3_bucket_arn             = aws_s3_bucket.this.arn
  secretsmanager_secret_arn = aws_secretsmanager_secret.this.arn
}
