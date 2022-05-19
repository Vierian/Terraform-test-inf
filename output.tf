output "BucketURL" {
  value = module.s3.BucketURL
}

output "CloudFrontURL" {
  value = module.cloudfront.CreatedDomain
}

