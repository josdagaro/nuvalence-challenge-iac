module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "put-nuva-data"
  description   = "My awesome lambda function for env ${var.env}"
  handler       = "index.lambda_handler"
  runtime       = "python3.6"

  source_path = "${path.module}/src"

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
