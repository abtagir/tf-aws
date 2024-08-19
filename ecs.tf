data "aws_secretsmanager_secret" "dockerhub" {
  name = "dockerhub-credentials"
}

data "aws_secretsmanager_secret_version" "dockerhub" {
  secret_id = data.aws_secretsmanager_secret.dockerhub.id
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "my-app"
    image     = var.container_image
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/my-app"
        awslogs-region        = "us-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }
    repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.dockerhub.arn
    }
  }])

  depends_on = [
    aws_iam_role.ecs_task_execution,
    aws_iam_role_policy_attachment.ecs_task_execution_policy,
    data.aws_secretsmanager_secret.dockerhub,
    data.aws_secretsmanager_secret_version.dockerhub
  ]
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/my-app"
  retention_in_days = 7
}

resource "aws_ecs_service" "app" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.allow_http.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "my-app"
    container_port   = 80
  }

  depends_on = [
    aws_lb.app,
    aws_lb_target_group.app,
    aws_lb_listener.app,
    aws_security_group.allow_http,
    aws_subnet.private,
    aws_subnet.public
  ]
}
