resource "aws_api_gateway_rest_api" "this" {
  count    = var.create ? 1 : 0
  provider = aws.ohio

  body = templatefile("${path.module}/OAS.json", {
    lambda_put_nuva_data_uri = module.lambda_function_put_nuva_data.lambda_function_invoke_arn
    lambda_get_nuva_data_uri = module.lambda_function_get_nuva_data.lambda_function_invoke_arn
  })

  name = "${var.env}-nuva-challenge"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  count       = var.create ? 1 : 0
  provider    = aws.ohio
  rest_api_id = try(aws_api_gateway_rest_api.this[0].id, "")

  triggers = {
    redeployment = sha1(jsonencode(try(aws_api_gateway_rest_api.this[0].body, "")))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  count         = var.create ? 1 : 0
  provider      = aws.ohio
  deployment_id = try(aws_api_gateway_deployment.this[0].id, "")
  rest_api_id   = try(aws_api_gateway_rest_api.this[0].id, "")
  stage_name    = var.env
}

resource "aws_api_gateway_usage_plan" "this" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  name     = "nuva-challenge"

  api_stages {
    api_id = try(aws_api_gateway_rest_api.this[0].id, "")
    stage  = try(aws_api_gateway_stage.this[0].stage_name, "")
  }

  quota_settings {
    limit  = 50
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_api_key" "this" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  name     = "${var.env}-consumer-key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count         = var.create ? 1 : 0
  provider      = aws.ohio
  key_id        = try(aws_api_gateway_api_key.this[0].id, "")
  key_type      = "API_KEY"
  usage_plan_id = try(aws_api_gateway_usage_plan.this[0].id, "")
}

resource "aws_wafregional_geo_match_set" "geo_match_set" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  name     = "geo_match_set"

  geo_match_constraint {
    type  = "Country"
    value = "CO"
  }
}

resource "aws_wafregional_rule" "wafrule" {
  count       = var.create ? 1 : 0
  provider    = aws.ohio
  depends_on  = [aws_wafregional_geo_match_set.geo_match_set]
  name        = "tfWAFRule"
  metric_name = "tfWAFRule"

  predicate {
    data_id = try(aws_wafregional_geo_match_set.geo_match_set[0].id, "")
    negated = false
    type    = "GeoMatch"
  }
}

resource "aws_wafregional_web_acl" "waf_acl" {
  count    = var.create ? 1 : 0
  provider = aws.ohio

  depends_on = [
    aws_wafregional_geo_match_set.geo_match_set,
    aws_wafregional_rule.wafrule,
  ]

  name        = "tfWebACL"
  metric_name = "tfWebACL"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = try(aws_wafregional_rule.wafrule[0].id, "")
    type     = "REGULAR"
  }
}

resource "aws_wafregional_web_acl_association" "this" {
  count        = var.create ? 1 : 0
  provider     = aws.ohio
  resource_arn = try(aws_api_gateway_stage.this[0].arn, "")
  web_acl_id   = try(aws_wafregional_web_acl.waf_acl[0].id, "")
}
