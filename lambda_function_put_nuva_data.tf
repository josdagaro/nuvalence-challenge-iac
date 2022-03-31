module "lambda_function_put_nuva_data" {
  source = "terraform-aws-modules/lambda/aws"

  providers = {
    aws = aws.ohio
  }

  function_name                     = "put-nuva-data"
  description                       = "My awesome lambda function for env ${var.env}"
  handler                           = "index.lambda_handler"
  runtime                           = "python3.6"
  create                            = var.create
  create_role                       = var.create
  attach_cloudwatch_logs_policy     = var.create
  attach_network_policy             = var.create
  policies                          = compact([try(module.iam_policy_secret_db[0].arn, ""), try(module.iam_policy_put_s3_objects[0].arn, "")])
  vpc_subnet_ids                    = module.vpc.intra_subnets
  vpc_security_group_ids            = [module.vpc.default_security_group_id]
  cloudwatch_logs_retention_in_days = 7
  source_path                       = "${path.module}/lambda-functions-src/user_uploads.py"
  publish                           = true

  tags = {
    Env = var.env
  }

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${element(concat(aws_api_gateway_rest_api.this.*.execution_arn, [""]), 0)}/*/*/*"
    }
  }
}
