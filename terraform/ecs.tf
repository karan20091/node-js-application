resource "aws_cloudwatch_log_group" "app-logs" {
  name = "nodejs-app-logs"
}


resource "aws_ecs_cluster" "ecs-app" {
  name = "nodejs-app-cluster"

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.app-logs.name
      }
    }
  }
}


resource "aws_ecs_task_definition" "ecs_app_task" {
  family                   = "nodejsapp-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "0.5GB"

  container_definitions = jsonencode([
    {
      name  = "nodejs-app",
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/nodejs-app:latest",
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
        },
      ],
      secrets = [
        {
          name      = "MONGODB_URI",
          valueFrom = data.aws_secretsmanager_secret_version.documentdb-secrets.secret_string.arn,
        },
        {
          name      = "MONGODB_DBNAME",
          valueFrom = data.aws_secretsmanager_secret_version.documentdb-secrets.secret_string.arn,
        },
        {
          name      = "MONGODB_DBNAME",
          valueFrom = data.aws_secretsmanager_secret_version.documentdb-secrets.secret_string.arn,
        },
      ],
    },
  ])
}


resource "aws_lb" "app_lb" {
  name               = "nodejs-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      content      = "OK"
    }
  }
}

resource "aws_security_group" "ecs_task_sg" {
  name_prefix   = "ecs-task-"
  description   = "Security group for ECS tasks"
  vpc_id        = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.cidr] 
  }

   egress {
     from_port   = 0
     to_port     = 65535
     protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to anywhere (adjust as needed)
  }
}

resource "aws_ecs_service" "ecs-app_service" {
  name            = "nodejs-app-service"
  cluster         = aws_ecs_cluster.ecs-app.id
  task_definition = aws_ecs_task_definition.ecs_app_task.arn

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_task_sg.id]
  }

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_listener.app_lb_listener.default_action[0].target_group_arn
    container_name   = "nodejs-app"
    container_port   = 80
  }
}