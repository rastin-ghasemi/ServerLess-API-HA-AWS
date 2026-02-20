# Configure providers for multiple regions
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "primary"
      Owner       = "Rastin-Ghasemi"
      Project     = var.Project
      contact     = var.contact
    ManagedBy   = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
  default_tags {
    tags = {
      Environment = "Secondary"
      Owner       = "Rastin-Ghasemi"
      Project     = var.Project
      contact     = var.contact
    ManagedBy   = "Terraform"
    }
  }
}


