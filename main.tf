#initiating provider
provider "aws" {
  region = "us-east-1" #Todo remove the hard coded value
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
    from_port = 3000
    to_port   = 3000
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
  port        = 3000
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