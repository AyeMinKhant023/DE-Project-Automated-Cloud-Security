# ROLE 1: JUNIOR ANALYST (READ-ONLY)
# 1. The Group 
resource "aws_iam_group" "analysts" {
  name = "Security-Analyst-Group"
}

# 2. The Policy Attachment (Managed – ReadOnly Access)
resource "aws_iam_group_policy_attachment" "readonly_attach" {
  group      = aws_iam_group.analysts.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# 3. The User
resource "aws_iam_user" "junior_user" {
  name = "Junior-Analyst"
  tags = {
    Project = "DE-Cloud-Security"
    Environment = "Development"
    Owner = "AyeMinKhant"
  }
}

# 4. The Membership
resource "aws_iam_group_membership" "analyst_team" {
  name = "analyst-membership"
  users = [aws_iam_user.junior_user.name]
  group = aws_iam_group.analysts.name
}

# ================================================================

# ROLE 2: NETWORK ADMIN (VPC FULL ACCESS)
# 1. The Group
resource "aws_iam_group" "network_admins" {
  name = "Network-Admin-Group"
}

# 2. The Policy Atachment (Managed – VPC Full Access)
resource "aws_iam_group_policy_attachment" "vpc_full_attach" {
    group = aws_iam_group.network_admins.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# 3. The User
resource "aws_iam_user" "senior_user" {
  name = "Senior-Network-Engineer"
  tags = {
    Project = "DE-Cloud-Security"
    Environment = "Development"
    Owner = "AyeMinKhant"
  }
}

# 4. the Menbership
resource "aws_iam_group_membership" "network_admin_team" {
  name = "network-admin-membership"
  users = [aws_iam_user.senior_user.name]
  group = aws_iam_group.network_admins.name
}

