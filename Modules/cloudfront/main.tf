locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.s3_URL
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2"]
  }
  }

  enabled             = true
  #is_ipv6_enabled     = true
  comment             = "Website from ${var.s3_URL}"

  #aliases = [var.domain, "www.${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 1

  price_class = "PriceClass_100"

  tags = {
    Environment = "test"
  }

  restrictions{
    geo_restriction{
        restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
    #acm_certificate_arn = var.certificateARN
  }
}