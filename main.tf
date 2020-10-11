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