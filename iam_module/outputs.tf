# Codepipeline IAM Role Outputs
output "iam_aws_codepipeline_role_arn" {
  value = aws_iam_role.pipeline.arn
}

output "iam_aws_codepipeline_role_id" {
  value = aws_iam_role.pipeline.id
}

output "iam_aws_codepipeline_name" {
  value = aws_iam_role.pipeline.name
}

# Codebuild IAM Role Outputs
output "iam_aws_codebuild_role_arn" {
  value = aws_iam_role.codebuild.arn
}

output "iam_aws_codebuild_role_id" {
  value = aws_iam_role.codebuild.id
}

output "iam_aws_codebuild_role_name" {
  value = aws_iam_role.codebuild.name
}

# Codedeploy IAM Role Outputs

output "iam_aws_codedeploy_role_arn" {
  value = aws_iam_role.codedeploy.arn
}

output "iam_aws_codedeploy_role_id" {
  value = aws_iam_role.codedeploy.id
}

output "iam_aws_codedeploy_role_name" {
  value = aws_iam_role.codedeploy.name
}

# ECS IAM Role Outputs
output "iam_ecs_task_role_arn" {
  value = aws_iam_role.task_role.arn
}

output "iam_ecs_task_role_id" {
  value = aws_iam_role.task_role.id
}

output "iam_ecs_task_role_name" {
  value = aws_iam_role.task_role.name
}

output "iam_ecs_execution_role_arn" {
  value = aws_iam_role.execution_role.arn
}

output "iam_ecs_execution_role_id" {
  value = aws_iam_role.execution_role.id
}

output "iam_ecs_execution_role_name" {
  value = aws_iam_role.execution_role.name
}