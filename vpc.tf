module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = aws.ohio
  }

  create_vpc = var.create
  name       = "nuva-vpc"
  cidr       = "10.10.0.0/16"

  # Specify at least one of: intra_subnets, private_subnets, or public_subnets
  azs           = ["us-east-2a", "us-east-2b", "us-east-2c"]
  intra_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
}
