resource "aws_s3_bucket" "this" {
  bucket        = "codepipeline-s3-${random_pet.this.id}"
  force_destroy = true
  tags = merge(local.common_tags,
    {
      "Component" = "CI/CD",
    }
  )
}

resource "aws_codebuild_project" "this" {
  name         = "codebuild-project-${random_pet.this.id}"
  description  = "Codebuild for the ECS Green/Blue app"
  service_role = module.global_iam.iam_aws_codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.this.repository_url
    }

    environment_variable {
      name  = "TASK_DEFINITION"
      value = "arn:aws:ecs:${var.region}:${var.account_id}:task-definition/${aws_ecs_task_definition.this.family}"
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = local.container_name
    }

    environment_variable {
      name  = "SUBNET_1"
      value = aws_subnet.this.*.id[0]
    }

    environment_variable {
      name  = "SUBNET_2"
      value = aws_subnet.this.*.id[1]
    }

    environment_variable {
      name  = "SUBNET_3"
      value = aws_subnet.this.*.id[2]
    }

    environment_variable {
      name  = "SECURITY_GROUP"
      value = aws_security_group.this.id
    }

  }

  source {
    type = "CODEPIPELINE"
  }
  tags = merge(local.common_tags,
    {
      "Component" = "CI/CD",
    }
  )
}

resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "ecs-deploy-app-${random_pet.this.id}"
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = "ecs-deploy-group-${random_pet.this.id}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = module.global_iam.iam_aws_codedeploy_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.this.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.this.arn]
      }

      target_group {
        name = aws_lb_target_group.this.*.name[0]
      }

      target_group {
        name = aws_lb_target_group.this.*.name[1]
      }
    }
  }
}

resource "aws_codepipeline" "this" {
  name     = "codepipeline-${random_pet.this.id}"
  role_arn = module.global_iam.iam_aws_codepipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }


  stage {
    name = "BuildAndTest"

    action {
      name             = "BuildAndTest"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.this.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.this.deployment_group_name
        TaskDefinitionTemplateArtifact = "build_output"
        AppSpecTemplateArtifact        = "build_output"
      }
    }
  }
  tags = merge(local.common_tags,
    {
      "Component" = "CI/CD",
    }
  )
}