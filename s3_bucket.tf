resource "aws_s3_bucket" "this" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  bucket   = "${var.env}-uploaded-nuva-challenge-files"

  tags = {
    Name = "uploaded-nuva-challenge-files"
    Env  = var.env
  }
}

resource "aws_s3_bucket_acl" "example" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  bucket   = try(aws_s3_bucket.this[0].id, null)
  acl      = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  count    = var.create ? 1 : 0
  provider = aws.ohio
  bucket   = try(aws_s3_bucket.this[0].id, null)

  rule {
    id = "rule-1"
    filter {}

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}
