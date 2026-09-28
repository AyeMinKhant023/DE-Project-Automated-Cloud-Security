# 1. AWS WAF v2 Regional Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = "de-project-web-acl"
  description = "Edge perimeter defense for Application Load Balancer"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1 (Priority 10): Core OWASP Top 10 Protections
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2 (Priority 20): SQL Injection Protections (Protects RDS MySQL)
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3 (Priority 30): Rate Limiting (DDoS & Brute Force Prevention)
  rule {
    name     = "RateLimitPerIP"
    priority = 30

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIPMetric"
      sampled_requests_enabled   = true
    }
  }

  # Overall WebACL CloudWatch Metrics
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DEProjectWebACLMetric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "DE-Project-WebACL"
  }
}

# 2. Association: Bind WebACL to the ALB
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
