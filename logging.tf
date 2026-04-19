# 1. This tells Terraform to find your AWS Account ID automatically
data "aws_caller_identity" "current" {}

# 2. The Storage Room (S3 Bucket)
resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "de-project-logs-${random_id.id.hex}"
  force_destroy = true # Allows 'terraform destroy' to delete the bucket even if it has logs
}

# 3. THE FIX: The Authorization Policy
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail_logs.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

# 4. The CCTV Camera (CloudTrail)
resource "aws_cloudtrail" "main_trail" {
  name                          = "DE-Project-Audit-Trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  # CRITICAL: This tells Terraform: "Don't turn on the camera until the policy is ready!"
  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]
}