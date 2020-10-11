#initiating provider
provider "aws" {
    region = "us-east-1"
}

#create AWS ecr repo to manage servian docker image
resource "aws_ecr_repository" "servian_ecr_repo" {
  name = "servian-ecr-repo" # Naming repo
}

#Create AWS ecs cluster to deploy docker container
resource "aws_ecs_cluster" "servian_ecs_cluster" {
  name = "servian-ecs-cluster" # Naming the cluster
}


#Creating AWS ecs task definition to run servian docker container on
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
  memory                   = 512         # memory for container 
  cpu                      = 256         # CPU for container 
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"

}
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {


  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}