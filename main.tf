module "s3" {
  source    = "./modules/s3"
  namespace = var.namespace
}

module "cloudfront"{
  source    = "./modules/cloudfront"
  namespace = var.namespace
  s3_URL    = module.s3.BucketURL
  #domain = var.domain
  #certificateARN = module.route53.certARN
}

module "codepipeline"{
  source    = "./modules/codepipeline"
  namespace = var.namespace
  BucketId = module.s3.BucketId
  BucketARN = module.s3.BucketARN
  repository = var.repository
  region = var.region
}

#Module for DNS, not having free domain rn.
#module "route53"{
#  source    = "./modules/route53"
#  namespace = var.namespace
#  domain = var.domain
#}