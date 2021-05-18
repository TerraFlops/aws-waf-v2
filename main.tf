
# Create IP set for the whitelist
resource "aws_wafv2_ip_set" "ip_whitelist" {
  name = "${var.name}IpWhitelist"
  description = "${var.name} IP Address whitelist"
  scope = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses = var.ip_whitelist
}

# Create IP set for the blacklist
resource "aws_wafv2_ip_set" "ip_blacklist" {
  depends_on = [
    aws_wafv2_ip_set.ip_whitelist
  ]
  name = "${var.name}IpBlacklist"
  description = "${var.name} IP Address blacklist"
  scope = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses = var.ip_blacklist
}

# Create WAF ACL for Debi CloudFront distributions
resource "aws_wafv2_web_acl" "web_acl" {
  depends_on = [
    aws_wafv2_ip_set.ip_blacklist,
    aws_wafv2_ip_set.ip_whitelist
  ]
  name = "${var.name}WebAcl"
  description = "${var.name} Web ACL"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Configure CloudWatch
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name = "${var.name}WebAcl"
    sampled_requests_enabled = false
  }

  # Rule 1: IP Address Blacklist
  dynamic "rule" {
    # This is a kludge to enable/disable the rule block- either passing a dummy set with a single value, or an empty set to bypass the rule
    for_each = length(var.ip_blacklist) > 0 ? toset([ "dummy-value" ]) : toset([])
    content {
      name = "${var.name}IpBlacklist"
      priority = 1
      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name = "${var.name}IpBlacklist"
        sampled_requests_enabled = false
      }
      action {
        block {}
      }
      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.ip_blacklist.arn
        }
      }
    }
  }

  # Rule 2: URL Blacklist
  dynamic "rule" {
    # This is a kludge to enable/disable the rule block- either passing a dummy set with a single value, or an empty set to bypass the rule
    for_each = length(var.url_blacklist) > 0 ? toset(["dummy-value"]) : toset([])
    content {
      name = "${var.name}UrlBlacklist"
      priority = 1 + (length(var.ip_blacklist) > 0 ? 1 : 0)
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name = "${var.name}UrlBlacklist"
        sampled_requests_enabled = false
      }
      dynamic "statement" {
        for_each = var.url_blacklist
        content {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string = statement.value
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type = "LOWERCASE"
            }
          }
        }
      }
    }
  }

  # Rule 3: IP Address Whitelist
  dynamic "rule" {
    # This is a kludge to enable/disable the rule block- either passing a dummy set with a single value, or an empty set to bypass the rule
    for_each = length(var.ip_whitelist) > 0 ? toset([ "dummy-value" ]) : toset([])
    content {
      name = "${var.name}IpWhitelist"
      priority = 1 + (length(var.ip_blacklist) > 0 ? 1 : 0) + (length(var.url_blacklist) > 0 ? 1 : 0)
      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name = aws_wafv2_ip_set.ip_whitelist.name
        sampled_requests_enabled = false
      }
      action {
        allow {}
      }
      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.ip_whitelist.arn
        }
      }
    }
  }

  # Rule 4: URL Whitelist
  dynamic "rule" {
    # This is a kludge to enable/disable the rule block- either passing a dummy set with a single value, or an empty set to bypass the rule
    for_each = length(var.url_whitelist) > 0 ? toset(["dummy-value"]) : toset([])
    content {
      name = "${var.name}UrlWhitelist"
      priority = 1 + (length(var.ip_blacklist) > 0 ? 1 : 0) + (length(var.url_blacklist) > 0 ? 1 : 0) + (length(var.ip_whitelist) > 0 ? 1 : 0)
      action {
        allow {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name = "${var.name}UrlWhitelist"
        sampled_requests_enabled = false
      }
      dynamic "statement" {
        for_each = var.url_whitelist
        content {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string = statement.value
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type = "LOWERCASE"
            }
          }
        }
      }
    }
  }

  # Rule 5+: AWS Managed Firewall Rules
  dynamic "rule" {
    for_each = [
      for rule in sort(toset(var.managed_rules)): {
        name = rule
        priority = index(var.managed_rules, rule) + 1
      }
    ]
    content {
      name = rule.value["name"]
      priority = rule.value["priority"] + (length(var.ip_blacklist) > 0 ? 1 : 0) + (length(var.url_blacklist) > 0 ? 1 : 0) + (length(var.ip_whitelist) > 0 ? 1 : 0) + (length(var.url_whitelist) > 0 ? 1 : 0)
      override_action {
        none {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name = "${var.name}${rule.value["name"]}"
        sampled_requests_enabled = false
      }
      statement {
        managed_rule_group_statement {
          name = rule.value["name"]
          vendor_name = "AWS"
        }
      }
    }
  }
}
