###########################################
# Health Checks for Both Regions
###########################################

# Health check for primary region
resource "aws_route53_health_check" "primary" {
  provider = aws.primary
  
  fqdn              = aws_api_gateway_domain_name.primary.regional_domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/read"  # Health check hits the /read endpoint
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "primary-api-health-check"
  }
}

# Health check for secondary region
resource "aws_route53_health_check" "secondary" {
  provider = aws.secondary
  
  fqdn              = aws_api_gateway_domain_name.secondary.regional_domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/read"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "secondary-api-health-check"
  }
}

###########################################
# Failover DNS Records
###########################################

# Primary failover record
resource "aws_route53_record" "primary_failover" {
  provider = aws.primary
  
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "api.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.primary.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.primary.regional_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id
}

# Secondary failover record
resource "aws_route53_record" "secondary_failover" {
  provider = aws.primary  # Records are created in primary region's Route 53
  
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "api.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.secondary.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.secondary.regional_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "secondary"
  health_check_id = aws_route53_health_check.secondary.id
}

###########################################
# Optional: Test endpoints
###########################################

# Direct endpoint for primary region (bypass failover)
resource "aws_route53_record" "primary_direct" {
  provider = aws.primary
  
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "primary.api.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.primary.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.primary.regional_zone_id
    evaluate_target_health = true
  }
}

# Direct endpoint for secondary region
resource "aws_route53_record" "secondary_direct" {
  provider = aws.primary
  
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "secondary.api.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.secondary.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.secondary.regional_zone_id
    evaluate_target_health = true
  }
}