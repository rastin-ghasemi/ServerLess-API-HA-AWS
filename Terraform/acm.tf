###########################################
# Data source for Route 53 hosted zone
###########################################
data "aws_route53_zone" "zone" {
  provider = aws.primary  # Route 53 is global, but specify provider
  name     = var.dns_zone_name
  private_zone = false
}

###########################################
# Primary Region ACM Certificate (us-east-1)
###########################################
resource "aws_acm_certificate" "primary" {
  provider = aws.primary
  
  domain_name       = "api.${var.dns_zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "api-${var.dns_zone_name}-primary"
    Environment = "production-primary"
  }
}

# DNS validation records for primary certificate
resource "aws_route53_record" "primary_validation" {
  provider = aws.primary
  for_each = {
    for dvo in aws_acm_certificate.primary.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "primary" {
  provider = aws.primary
  
  certificate_arn         = aws_acm_certificate.primary.arn
  validation_record_fqdns = [for record in aws_route53_record.primary_validation : record.fqdn]
}

###########################################
# Secondary Region ACM Certificate (us-west-2)
###########################################
resource "aws_acm_certificate" "secondary" {
  provider = aws.secondary
  
  domain_name       = "api.${var.dns_zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "api-${var.dns_zone_name}-secondary"
    Environment = "production-secondary"
  }
}

# DNS validation records for secondary certificate
resource "aws_route53_record" "secondary_validation" {
  provider = aws.secondary
  for_each = {
    for dvo in aws_acm_certificate.secondary.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id  # Same hosted zone
}

# Certificate validation
resource "aws_acm_certificate_validation" "secondary" {
  provider = aws.secondary
  
  certificate_arn         = aws_acm_certificate.secondary.arn
  validation_record_fqdns = [for record in aws_route53_record.secondary_validation : record.fqdn]
}