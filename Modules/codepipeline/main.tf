resource "aws_codepipeline" "codepipeline" {
  name     = "${var.namespace}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.connection.arn
        FullRepositoryId = "${var.repository}"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
      ProjectName    = "${var.namespace}-project"
      EnvironmentVariables = jsonencode(
          [
            {
              name  = "oauth_consumer_key"
              type  = "PLAINTEXT"
              value = "QOj9L9T4MaDRr15PmBX8bPaz1OuTe1emdMWCC7tP"
            },
            {
              name  = "oauth_secret"
              type  = "PLAINTEXT"
              value = "5D59V419H649cKtpPpzzkRzPcYncx1WnvTwidkQN"
            },
            {
              name  = "url"
              type  = "PLAINTEXT"
              value = "https://www.openstreetmap.org"
            },
          ]
        )
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName     = "${var.BucketId}"
        Extract        = true
      }
    }
  }
}

resource "aws_codebuild_project" "project"{
  name          = "${var.namespace}-project"
  description   = "${var.namespace}-project"
  build_timeout = "5"
  service_role  = aws_iam_role.codepipeline_role.arn
  artifacts{
    type = "CODEPIPELINE"
  }
  environment{
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:2.0"
    type         = "LINUX_CONTAINER"
  }
  source{
    type        = "CODEPIPELINE"
    buildspec  = <<EOF
version: 0.2

phases:
  build:
    commands:
      - echo Build started on `date`
      - echo Updating OSM integration
      - sed -i "s/<< oauth_consumer_key >>/$${oauth_consumer_key}/;s/<< oauth_secret >>/$${oauth_secret}/;s|<< url >>|$${url}|" ./web/js/osm-integration.js
      - python -m pip install -r requirements.txt
      - python download_data.py ./web
  post_build:
    commands:
      - echo Build completed on `date`
artifacts:
  files:
    - '**/*'
  base-directory: web
  name: AED-artifacts
EOF
  }
}

resource "aws_codestarconnections_connection" "connection" {
  name          = "${var.namespace}-connection"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.namespace}-pipeline-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.namespace}-pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["codepipeline.amazonaws.com",
                    "codebuild.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.namespace}-pipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*",
        "${var.BucketARN}",
        "${var.BucketARN}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.connection.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_key" "s3kmskey" {
  description             = "${var.namespace}-Kms-pipeline-Key"
}