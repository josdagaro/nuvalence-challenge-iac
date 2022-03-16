module "iam_policy_secret_db" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"
  count   = var.create ? 1 : 0

  providers = {
    aws = aws.ohio
  }

  name        = "read-only-scrt-db-creds"
  path        = "/"
  description = "My nuva DB Secretpolicy"

  policy = templatefile("${path.module}/secret-policy.json", {
    secrets = "[${join(",", [for arn in compact([try(aws_secretsmanager_secret.this[0].arn, "")]) : format("%q", arn)])}]"
  })
}

module "iam_policy_put_s3_objects" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"
  count   = var.create ? 1 : 0

  providers = {
    aws = aws.ohio
  }

  name        = "put-s3-objects"
  path        = "/"
  description = "My nuva S3 PUT policy"

  policy = templatefile("${path.module}/s3-put-object-policy.json", {
    s3_bucket = try("${aws_s3_bucket.this[0].arn}/*", "")
  })
}

module "iam_policy_get_s3_objects" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"
  count   = var.create ? 1 : 0

  providers = {
    aws = aws.ohio
  }

  name        = "get-s3-objects"
  path        = "/"
  description = "My nuva S3 GET policy"

  policy = templatefile("${path.module}/s3-get-objects-policy.json", {
    s3_buckets = "[${join(",", [for arn in compact([try("${aws_s3_bucket.this[0].arn}/*", "")]) : format("%q", arn)])}]"
  })
}
