
# Create the DynamoDB table with replica configuration
resource "aws_dynamodb_table" "this" {
  provider         = aws.primary
  name             = var.DynamoDB-name
  billing_mode     = "PAY_PER_REQUEST"  # Recommended for global tables
  hash_key         = "ItemId"
  
  # Define attributes
  attribute {
    name = "ItemId"
    type = "S"
  }

  # Enable streams (required for Global Tables)
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Configure replicas
  replica {
    region_name = "us-west-2"
  }

  # Optional: Enable point-in-time recovery for disaster recovery
  point_in_time_recovery {
    enabled = true
  }

  # Prevent accidental deletion of critical table
  lifecycle {
    # In Real World We Make This True
    prevent_destroy = false
  }

  tags = {
    Name        = "HighAvailabilityTable"

  }
}