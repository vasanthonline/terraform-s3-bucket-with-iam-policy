terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "personal"
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::000000000000:role/ci-cd-role"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.bucket_name}-bucket-policy"
  description = "A policy with specific S3 permissions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:GetBucketCORS",
        "s3:ListBucket",
        "s3:GetBucketAcl",
        "s3:GetBucketPolicy",
        "s3:GetObjectVersion",
        "s3:ListMultipartUploadParts",
        "s3:PutBucketPolicy"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-policy-to-role" {
  role = "ci-cd-role"
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.example.id
  depends_on = [aws_s3_bucket.example, aws_iam_policy.policy]

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.bucket_name}-bucket-policy"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*",
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "8.8.8.8/32"
          }
        }
      },
    ]
  })
}


variable "bucket_name" {
  type = string
  default = "sample-bucket-via-tf"

  validation {
    condition     = can(regex("^sample-bucket-", var.bucket_name))
    error_message = "The bucket_name value must be a valid, starting with \"sample-bucket-\"."
  }
}
