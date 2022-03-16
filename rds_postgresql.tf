module "security_group_db" {
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

module "db" {
  source = "terraform-aws-modules/rds/aws"

  providers = {
    aws = aws.ohio
  }

  create_db_instance                    = var.create
  create_db_option_group                = var.create
  create_db_parameter_group             = var.create
  identifier                            = "${var.env}-nuva-db"
  engine                                = "postgres"
  engine_version                        = "10.20"
  family                                = "postgres10"
  major_engine_version                  = "10"
  instance_class                        = "db.t4g.large"
  allocated_storage                     = 20
  max_allocated_storage                 = 100
  db_name                               = "nuva"
  username                              = var.db_secret_user
  password                              = var.db_secret_pass
  port                                  = 5432
  multi_az                              = true
  create_db_subnet_group                = var.create
  db_subnet_group_name                  = "${var.env}-nuva-db"
  subnet_ids                            = module.vpc.intra_subnets
  vpc_security_group_ids                = [module.security_group_db.security_group_id]
  maintenance_window                    = "Mon:00:00-Mon:03:00"
  backup_window                         = "03:00-06:00"
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  create_cloudwatch_log_group           = var.create
  backup_retention_period               = 0 # In days
  skip_final_snapshot                   = true
  deletion_protection                   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7 # In days
  create_monitoring_role                = var.create
  monitoring_interval                   = 60 # In seconds
  monitoring_role_name                  = "nuva-db-monitoring"
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = {
    Env = var.env
  }

  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}
