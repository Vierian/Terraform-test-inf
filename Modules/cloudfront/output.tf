output "CreatedDomain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
