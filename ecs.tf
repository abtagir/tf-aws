data "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
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
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

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
        awslogs-region        = "us-west-2" # Replace with your region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
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
}
