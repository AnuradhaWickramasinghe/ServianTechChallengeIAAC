output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = aws_alb.application_load_balancer.dns_name
}

output "db_connection_endpoint" {
  value = aws_db_instance.default.address
}

output "ecr_repo_name" {
  value = aws_ecr_repository.servian_ecr_repo.name
}
output "ecr_repository_url" {
  value = aws_ecr_repository.servian_ecr_repo.repository_url
}

output "ecr_registry_id" {
  value = aws_ecr_repository.servian_ecr_repo.registry_id
}