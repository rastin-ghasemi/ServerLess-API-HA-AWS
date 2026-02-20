/*
I'll explain how to create an API Gateway step by step, breaking down each component and why we need it. Let's start with the basics and build up to a complete API.

Understanding API Gateway Components
Think of API Gateway like a restaurant:

REST API = The restaurant itself

Resources = Different sections of the menu (/read, /write)

Methods = What you want to do (GET = read data, POST = create data)

Integration = The kitchen that prepares your food (Lambda functions)

Deployment = Opening the restaurant for business

Stage = Different versions (prod = main restaurant, dev = test kitchen)

CORS = Rules about who can enter (like a VIP list)

*/



###############################
# Step 1: Create the REST API #
###############################
# Primary Region API Gateway
resource "aws_api_gateway_rest_api" "primary_api" {
  provider    = aws.primary
  name        = "HighAvailabilityAPI"
  description = "High Availability API for multi-region failover"

  endpoint_configuration {
    types = ["REGIONAL"]  # REGIONAL for region-specific, EDGE for global
  }
}

###################################
# Step 2: Create Resources ########
###################################
# /read resource
resource "aws_api_gateway_resource" "read_resource_primary" {
  provider    = aws.primary
  rest_api_id = aws_api_gateway_rest_api.primary_api.id
  parent_id   = aws_api_gateway_rest_api.primary_api.root_resource_id  # This is the "/"
  path_part   = "read"  # This creates "/read"
}

# /write resource
resource "aws_api_gateway_resource" "write_resource_primary" {
  provider    = aws.primary
  rest_api_id = aws_api_gateway_rest_api.primary_api.id
  parent_id   = aws_api_gateway_rest_api.primary_api.root_resource_id
  path_part   = "write"  # This creates "/write"
}

# Why we need this: Resources define the URL paths like https://api.example.com/read and https://api.example.com/write.

###############################
# Step 3: Create HTTP Methods #
###############################
# GET method for /read (retrieve data)
resource "aws_api_gateway_method" "read_get_primary" {
  provider      = aws.primary
  rest_api_id   = aws_api_gateway_rest_api.primary_api.id
  resource_id   = aws_api_gateway_resource.read_resource_primary.id
  http_method   = "GET"  # HTTP method
  authorization = "NONE"  # No authentication required
  
  # For CORS support
  request_parameters = {
    "method.request.header.Origin" = false
  }
}

# POST method for /write (create data)
resource "aws_api_gateway_method" "write_post_primary" {
  provider      = aws.primary
  rest_api_id   = aws_api_gateway_rest_api.primary_api.id
  resource_id   = aws_api_gateway_resource.write_resource_primary.id
  http_method   = "POST"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.header.Origin" = false
  }
}

###########################################
# Step 4: Connect to Lambda (Integration) #
###########################################
# Connect GET method to ReadFunction
resource "aws_api_gateway_integration" "read_get_integration_primary" {
  provider                = aws.primary
  rest_api_id             = aws_api_gateway_rest_api.primary_api.id
  resource_id             = aws_api_gateway_resource.read_resource_primary.id
  http_method             = aws_api_gateway_method.read_get_primary.http_method
  integration_http_method = "POST"  # Lambda always uses POST
  type                    = "AWS_PROXY"  # Proxy passes everything to Lambda
  uri                     = aws_lambda_function.read_function_primary.invoke_arn
}

# Connect POST method to WriteFunction
resource "aws_api_gateway_integration" "write_post_integration_primary" {
  provider                = aws.primary
  rest_api_id             = aws_api_gateway_rest_api.primary_api.id
  resource_id             = aws_api_gateway_resource.write_resource_primary.id
  http_method             = aws_api_gateway_method.write_post_primary.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.write_function_primary.invoke_arn
}

# Why AWS_PROXY? It automatically passes the entire HTTP request to Lambda and returns Lambda's response to the client. 

########################################################
# Step 5: Handle CORS (Cross-Origin Resource Sharing) ##
########################################################

# CORS is like security policy for web browsers. When your frontend (from one domain) tries to call your API (from another domain), browsers block it unless CORS is enabled:
# OPTIONS method for /read (CORS preflight)
resource "aws_api_gateway_method" "read_options_primary" {
  provider      = aws.primary
  rest_api_id   = aws_api_gateway_rest_api.primary_api.id
  resource_id   = aws_api_gateway_resource.read_resource_primary.id
  http_method   = "OPTIONS"  # Browser sends this first to check permissions
  authorization = "NONE"
}

# Mock integration for OPTIONS (doesn't call Lambda)
resource "aws_api_gateway_integration" "read_options_integration_primary" {
  provider      = aws.primary
  rest_api_id   = aws_api_gateway_rest_api.primary_api.id
  resource_id   = aws_api_gateway_resource.read_resource_primary.id
  http_method   = aws_api_gateway_method.read_options_primary.http_method
  type          = "MOCK"  # Returns a response without calling backend
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Response with CORS headers
resource "aws_api_gateway_method_response" "read_options_response_primary" {
  provider    = aws.primary
  rest_api_id = aws_api_gateway_rest_api.primary_api.id
  resource_id = aws_api_gateway_resource.read_resource_primary.id
  http_method = aws_api_gateway_method.read_options_primary.http_method
  status_code = "200"

  # These headers tell browsers it's safe to call from any origin
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration response with actual header values
resource "aws_api_gateway_integration_response" "read_options_integration_response_primary" {
  provider    = aws.primary
  rest_api_id = aws_api_gateway_rest_api.primary_api.id
  resource_id = aws_api_gateway_resource.read_resource_primary.id
  http_method = aws_api_gateway_method.read_options_primary.http_method
  status_code = aws_api_gateway_method_response.read_options_response_primary.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"  # Allowed methods
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"  # Allow any origin
  }
}
###########################################
# Deploy Primary API
###########################################

# Deploy the primary API
resource "aws_api_gateway_deployment" "primary" {
  provider    = aws.primary
  rest_api_id = aws_api_gateway_rest_api.primary_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.read_resource_primary.id,
      aws_api_gateway_resource.write_resource_primary.id,
      aws_api_gateway_method.read_get_primary.id,
      aws_api_gateway_method.write_post_primary.id,
      aws_api_gateway_integration.read_get_integration_primary.id,
      aws_api_gateway_integration.write_post_integration_primary.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create primary stage
resource "aws_api_gateway_stage" "primary" {
  provider      = aws.primary
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.primary_api.id
  deployment_id = aws_api_gateway_deployment.primary.id

  variables = {
    "region" = "primary"
  }
}

###########################################
# SECONDARY REGION (e.g., us-west-2)
###########################################

# 1. Create the REST API in secondary region
resource "aws_api_gateway_rest_api" "secondary_api" {
  provider    = aws.secondary
  name        = "HighAvailabilityAPI"
  description = "High Availability API in secondary region"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# 2. Create /read resource in secondary region
resource "aws_api_gateway_resource" "secondary_read" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id
  parent_id   = aws_api_gateway_rest_api.secondary_api.root_resource_id
  path_part   = "read"
}

# 3. Create /write resource in secondary region
resource "aws_api_gateway_resource" "secondary_write" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id
  parent_id   = aws_api_gateway_rest_api.secondary_api.root_resource_id
  path_part   = "write"
}

# 4. OPTIONS method for /read (CORS preflight) in secondary region
resource "aws_api_gateway_method" "secondary_read_options" {
  provider      = aws.secondary
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  resource_id   = aws_api_gateway_resource.secondary_read.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "secondary_read_options" {
  provider      = aws.secondary
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  resource_id   = aws_api_gateway_resource.secondary_read.id
  http_method   = aws_api_gateway_method.secondary_read_options.http_method
  type          = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "secondary_read_options_response" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id
  resource_id = aws_api_gateway_resource.secondary_read.id
  http_method = aws_api_gateway_method.secondary_read_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "secondary_read_options_integration_response" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id
  resource_id = aws_api_gateway_resource.secondary_read.id
  http_method = aws_api_gateway_method.secondary_read_options.http_method
  status_code = aws_api_gateway_method_response.secondary_read_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.secondary_read_options]
}

# 5. GET method for /read in secondary region
resource "aws_api_gateway_method" "secondary_read_get" {
  provider      = aws.secondary
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  resource_id   = aws_api_gateway_resource.secondary_read.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "secondary_read_get" {
  provider                = aws.secondary
  rest_api_id             = aws_api_gateway_rest_api.secondary_api.id
  resource_id             = aws_api_gateway_resource.secondary_read.id
  http_method             = aws_api_gateway_method.secondary_read_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.read_function_secondary.invoke_arn
}

# 6. OPTIONS method for /write in secondary region
resource "aws_api_gateway_method" "secondary_write_options" {
  provider      = aws.secondary
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  resource_id   = aws_api_gateway_resource.secondary_write.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "secondary_write_options" {
  provider      = aws.secondary
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  resource_id   = aws_api_gateway_resource.secondary_write.id
  http_method   = aws_api_gateway_method.secondary_write_options.http_method
  type          = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "secondary_write_options_response" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id
  resource_id = aws_api_gateway_resource.secondary_write.id
  http_method = aws_api_gateway_method.secondary_write_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "secondary_write_options_integration_response" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id
  resource_id = aws_api_gateway_resource.secondary_write.id
  http_method = aws_api_gateway_method.secondary_write_options.http_method
  status_code = aws_api_gateway_method_response.secondary_write_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.secondary_write_options]
}

# 7. POST method for /write in secondary region
resource "aws_api_gateway_method" "secondary_write_post" {
  provider      = aws.secondary
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  resource_id   = aws_api_gateway_resource.secondary_write.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "secondary_write_post" {
  provider                = aws.secondary
  rest_api_id             = aws_api_gateway_rest_api.secondary_api.id
  resource_id             = aws_api_gateway_resource.secondary_write.id
  http_method             = aws_api_gateway_method.secondary_write_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.write_function_secondary.invoke_arn
}

# 8. Deploy the secondary API
resource "aws_api_gateway_deployment" "secondary" {
  provider    = aws.secondary
  rest_api_id = aws_api_gateway_rest_api.secondary_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.secondary_read.id,
      aws_api_gateway_resource.secondary_write.id,
      aws_api_gateway_method.secondary_read_get.id,
      aws_api_gateway_method.secondary_write_post.id,
      aws_api_gateway_integration.secondary_read_get.id,
      aws_api_gateway_integration.secondary_write_post.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 9. Create secondary stage
resource "aws_api_gateway_stage" "secondary" {
  provider      = aws.secondary
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.secondary_api.id
  deployment_id = aws_api_gateway_deployment.secondary.id

  variables = {
    "region" = "secondary"
  }
}

