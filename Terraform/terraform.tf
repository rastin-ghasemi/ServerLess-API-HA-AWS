terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket               = "my-terraform-state-bucket-1761834673"
    key                  = "state-ServerLess-Deploy"
    workspace_key_prefix = "tf_state_deploy"
    region               = "us-east-1"
    dynamodb_table       = "terraform-state-locking"
    encrypt              = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}