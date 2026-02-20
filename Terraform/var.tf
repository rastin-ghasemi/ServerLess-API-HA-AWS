variable "Project" {
  description = "The name of project"
  default     = "HA-ServerLess"
}

variable "contact" {
  description = "Who Responsible for this Infra"
  default     = "rastinghasemi5@gmail.com"
}

variable "DynamoDB-name" {
  description = "Name of our Global DB"
  default     = "HighAvailabilityTable"
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "LambdaDynamoDBRole"
}

variable "dns_zone_name" {
  description = "Domain Name"
  type        = string
  default     = "ghost-rider.click"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-west-2"
}