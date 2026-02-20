# Output the role ARNs
output "primary_lambda_role_arn" {
  description = "ARN of the LambdaDynamoDBRole in primary region"
  value       = aws_iam_role.lambda_dynamodb_role_primary.arn
}

output "secondary_lambda_role_arn" {
  description = "ARN of the LambdaDynamoDBRole in secondary region"
  value       = aws_iam_role.lambda_dynamodb_role_secondary.arn
}

# Output API endpoints
output "primary_api_endpoint" {
  value = "${aws_api_gateway_stage.primary.invoke_url}/read"
  description = "Primary region API endpoint for /read"
}

output "primary_api_write_endpoint" {
  value = "${aws_api_gateway_stage.primary.invoke_url}/write"
  description = "Primary region API endpoint for /write"
}

output "secondary_api_endpoint" {
  value = "${aws_api_gateway_stage.secondary.invoke_url}/read"
  description = "Secondary region API endpoint for /read"
}

output "secondary_api_write_endpoint" {
  value = "${aws_api_gateway_stage.secondary.invoke_url}/write"
  description = "Secondary region API endpoint for /write"
}

# Output custom domain endpoints
output "custom_domain_endpoint" {
  value = "https://api.${var.dns_zone_name}/read"
  description = "Custom domain endpoint with failover"
}

output "primary_direct_endpoint" {
  value = "https://primary.api.${var.dns_zone_name}/read"
  description = "Direct endpoint for primary region"
}

output "secondary_direct_endpoint" {
  value = "https://secondary.api.${var.dns_zone_name}/read"
  description = "Direct endpoint for secondary region"
}

# Output health check IDs
output "primary_health_check_id" {
  value = aws_route53_health_check.primary.id
  description = "Health check ID for primary region"
}

output "secondary_health_check_id" {
  value = aws_route53_health_check.secondary.id
  description = "Health check ID for secondary region"
}