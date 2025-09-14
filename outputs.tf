output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app.name
}

output "rds_cluster_endpoint" {
  description = "RDS Cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "RDS Cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "secrets_manager_arn" {
  description = "Secrets Manager ARN for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

# Temporarily disabled S3 and CloudFront outputs for testing
# output "s3_bucket_name" {
#   description = "S3 bucket name for media files"
#   value       = aws_s3_bucket.media_files.bucket
# }

# output "s3_bucket_arn" {
#   description = "S3 bucket ARN for media files"
#   value       = aws_s3_bucket.media_files.arn
# }

# output "cloudfront_domain_name" {
#   description = "CloudFront distribution domain name"
#   value       = aws_cloudfront_distribution.media_files.domain_name
# }

# output "cloudfront_distribution_id" {
#   description = "CloudFront distribution ID"
#   value       = aws_cloudfront_distribution.media_files.id
# }
