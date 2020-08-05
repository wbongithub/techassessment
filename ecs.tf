resource "aws_ecr_repository" "this" {
  name = "${local.ecr_name}/${local.container_name}"
  # To keep pushing the Latest Tag, it should be mutable
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(local.common_tags,
    {
      "Component" = "ECS/Fargate",
    }
  )
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/ecs/${local.container_name}"
  tags = merge(local.common_tags,
    {
      "Component" = "ECS/Fargate",
    }
  )
}

module "container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.38.0"
  container_name  = local.container_name
  container_image = "${aws_ecr_repository.this.repository_url}:latest"

  port_mappings = [
    {
      containerPort = 8000
      hostPort      = 8000
      protocol      = "tcp"
    },
  ]

  secrets = [
    {
      name      = "DJANGO_CONFIG"
      valueFrom = aws_secretsmanager_secret.this.arn
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.region
      "awslogs-group"         = aws_cloudwatch_log_group.this.name
      "awslogs-stream-prefix" = "ecs"
    }
    secretOptions = null
  }

}

resource "aws_ecs_cluster" "this" {
  name = "example-cluster"
  tags = merge(local.common_tags,
    {
      "Component" = "ECS/Fargate",
    }
  )
}

resource "aws_ecs_task_definition" "this" {
  family                   = "green-blue-ecs-example"
  container_definitions    = "[${module.container_definition.json_map_encoded}]"
  execution_role_arn       = module.global_iam.iam_ecs_execution_role_arn
  task_role_arn            = module.global_iam.iam_ecs_task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  tags = merge(local.common_tags,
    {
      "Component" = "ECS/Fargate",
    }
  )
}

resource "aws_security_group" "this" {
  name   = "allow-ecs-traffic"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port       = 8000
    protocol        = "tcp"
    to_port         = 8000
    security_groups = [aws_security_group.these.id]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags,
    {
      "Component" = "ECS/Fargate",
    }
  )
}

resource "aws_ecs_service" "this" {
  name            = "example-service"
  task_definition = aws_ecs_task_definition.this.id
  cluster         = aws_ecs_cluster.this.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.this[0].arn
    container_name   = local.container_name
    container_port   = 8000
  }

  launch_type   = "FARGATE"
  desired_count = 3

  network_configuration {
    subnets         = aws_subnet.this.*.id
    security_groups = [aws_security_group.this.id]

    assign_public_ip = true
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }


  depends_on = [aws_lb_listener.this, aws_db_instance.this]

  // https://github.com/terraform-providers/terraform-provider-aws/issues/13192#issuecomment-632093962
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      load_balancer,
    ]
  }

}
