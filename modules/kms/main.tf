data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "rds_key" {
  description             = "Customer Managed Key for RDS Persistence Tier"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service to use the key via AWS RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "rds.${data.aws_region.current.id}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "DE-Project-RDS-CMK"
    Compliance  = "CIS-3.8-NIST-SC12"
    Environment = "Production"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/de-project-rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}
