output "BucketId" {
  value = aws_s3_bucket.www_bucket.id
}

output "BucketARN" {
  value = aws_s3_bucket.www_bucket.arn
}

output "BucketURL" {
  value = aws_s3_bucket_website_configuration.www_bucket.website_endpoint
}