module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.ohio
  }

  create      = var.create
  name        = "${var.env}-nuva-db"
  description = "PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = "${join(",", module.vpc.intra_subnets_cidr_blocks)}"
    },
  ]

  tags = {
    Env = var.env
  }
}
