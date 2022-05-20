locals {
  s3_origin_id = "${var.s3_URL}"
}

data "aws_cloudfront_cache_policy" "cache_policy" {
    name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.s3_URL
    origin_id   = local.s3_origin_id
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
  }
  }

  enabled             = true
  #is_ipv6_enabled     = true
  comment             = "Website from ${var.s3_URL}"

  #aliases = [var.domain, "www.${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    compress               = true
    cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id
    

    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1

  price_class = "PriceClass_100"

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