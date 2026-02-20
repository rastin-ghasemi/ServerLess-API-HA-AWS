###########################################
# Primary Region Custom Domain
###########################################
resource "aws_api_gateway_domain_name" "primary" {
  provider = aws.primary
  
  domain_name              = "api.${var.dns_zone_name}"
  regional_certificate_arn = aws_acm_certificate_validation.primary.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_acm_certificate_validation.primary
  ]
}

# Map primary custom domain to primary API
resource "aws_api_gateway_base_path_mapping" "primary" {
  provider = aws.primary
  
  api_id      = aws_api_gateway_rest_api.primary_api.id
  stage_name  = aws_api_gateway_stage.primary.stage_name
  domain_name = aws_api_gateway_domain_name.primary.domain_name
  base_path   = ""  # Empty means root path
}

###########################################
# Secondary Region Custom Domain
###########################################
resource "aws_api_gateway_domain_name" "secondary" {
  provider = aws.secondary
  
  domain_name              = "api.${var.dns_zone_name}"
  regional_certificate_arn = aws_acm_certificate_validation.secondary.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_acm_certificate_validation.secondary
  ]
}

# Map secondary custom domain to secondary API
resource "aws_api_gateway_base_path_mapping" "secondary" {
  provider = aws.secondary
  
  api_id      = aws_api_gateway_rest_api.secondary_api.id
  stage_name  = aws_api_gateway_stage.secondary.stage_name
  domain_name = aws_api_gateway_domain_name.secondary.domain_name
  base_path   = ""
}