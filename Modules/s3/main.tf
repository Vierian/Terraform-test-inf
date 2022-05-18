resource "random_pet" "www_bucket" {
  length = 1
}

locals {
  bucket_name = "${random_pet.www_bucket.id}-${var.namespace}"
}

resource "aws_s3_bucket" "www_bucket"{
    bucket = local.bucket_name
}

resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.www_bucket.arn,
          "${aws_s3_bucket.www_bucket.arn}/*",
        ]
      },
    ]
  })
}