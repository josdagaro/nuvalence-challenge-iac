provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

terraform {
  required_version = ">= 1.1.5, <= 1.1.7"

  required_providers {
    aws = "4.3.0" # Exact version to make sure we don't get undesired updates
  }
}
