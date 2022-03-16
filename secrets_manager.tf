data "aws_kms_key" "default_ssm_kms_key" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  key_id   = "alias/aws/secretsmanager"
}

resource "aws_secretsmanager_secret" "this" {
  count                   = var.create ? 1 : 0
  provider                = aws.ohio
  name                    = "${var.env}-nuva-db-credentials"
  recovery_window_in_days = 0
  kms_key_id              = try(data.aws_kms_key.default_ssm_kms_key[0].id, null)
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = var.create ? 1 : 0
  provider      = aws.ohio
  secret_id     = try(aws_secretsmanager_secret.this[0].id, null)
  secret_string = jsonencode({ user = var.db_secret_user, pass = var.db_secret_pass })
}
