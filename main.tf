#initiating provider
provider "aws" {
  region = "us-east-1" #Todo remove the hard coded value
}

#Create postgress RDS inside default VPC / Todo move RDS to private VPC
resource "aws_db_instance" "default" {
  identifier = "postgres"

  engine              = "postgres"
  engine_version      = "9.6.1" 
  instance_class      = "db.t2.micro"
  allocated_storage   = 5
  storage_encrypted   = false
  publicly_accessible = true  #make data base publically accsible to ease initial testing
  skip_final_snapshot = true
  name                = "app"
  username            = "postgres"
  password            = "changeme"
  port                = "5432"

  #vpc_security_group_ids = [data.aws_security_group.default.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "servian"
  }
  #deletion protection has been dissabled to ease testing
  deletion_protection = false
}

#create AWS ecr repo to manage servian docker image
resource "aws_ecr_repository" "servian_ecr_repo" {
  name = "servian-ecr-repo" # Naming repo
}

#Create AWS ecs cluster to deploy docker container
resource "aws_ecs_cluster" "servian_ecs_cluster" {
  name = "servian-ecs-cluster" # Naming the cluster
}


#Creating AWS ecs task definition to run servian docker container
#Todo remove the hard coded value "3000" and make it parameter prompt on terraform apply

resource "aws_ecs_task_definition" "first_task" {
  family                   = "first-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "first-task",
      "image": "${aws_ecr_repository.servian_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "command": [
        "serve"
      ],
       "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/first-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512 # memory for container 
  cpu                      = 256 # CPU for container 
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"

}
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

#aws policy document with aws to execute ecs task_definition
data "aws_iam_policy_document" "assume_role_policy" {


  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#attachnig aws policy document to aws managed ploicy
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# make reference to  default VPC
resource "aws_default_vpc" "default_vpc" {
}

# make reference to  default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a" #Todo remove the hard coded value
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b" #Todo remove the hard coded value
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c" #Todo remove the hard coded value
}

#Creating aws ALB
resource "aws_alb" "application_load_balancer" {
  name               = "app-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

#Creating aws ecs service to manage first-task
resource "aws_ecs_service" "first_service" {
  name            = "first-service"
  cluster         = "${aws_ecs_cluster.servian_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.first_task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 3 #Todo remove the hard coded value

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true

  }
}

resource "aws_security_group" "service_security_group" {
  name = "service-security-group"
  ingress {
    from_port = 3000 #Todo remove the hard coded value
    to_port   = 3000 #Todo remove the hard coded value
    protocol  = "TCP"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0      
    to_port     = 0             
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  name = "load-balancer-security-group"
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0             
    to_port     = 0             
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creating aws application load balance target group
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 3000 #Todo remove the hard coded value
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" # Referencing the default VPC
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

#Create aws ALB listner to listen 80 port and forward them to crated target group runs on port 3000
resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our tagrte group
  }
}