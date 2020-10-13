# Terraflops Terraform Module
 
### Module name

Insert module description

#### Example usage

```hcl-terraform
module "example_waf" {
  source = "git::https://github.com/TerraFlops/aws-waf-v2?ref=v1.19"
  providers = {
    aws = aws.us_east_1
  }

  name = "example-waf"
  allow_default_action = true
  create_logging_configuration = true
  waf_v2_logs_bucket = "example.waf-v2.dev.example.com.au"

  managed_rules = {
    10 = {
      managed_rule_name = "AWSManagedRulesCommonRuleSet"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled = true
      vendor_name = "AWS"
      excluded_rules = []
    }
    20 = {
      managed_rule_name = "AWSManagedRulesPHPRuleSet"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled = true
      vendor_name = "AWS"
      excluded_rules = []
    }
    30 = {
      managed_rule_name = "AWSManagedRulesKnownBadInputsRuleSet"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled = true
      vendor_name = "AWS"
      excluded_rules = []
    }
    40 = {
      managed_rule_name = "AWSManagedRulesSQLiRuleSet"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled = true
      vendor_name = "AWS"
      excluded_rules = []
    }
  }

  ip_sets_rule = {
    50 = {
      name = "EonxAllowedIps"
      action = "allow"
      ip_set_arn = module.eonx_office_ip_set.arn
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled = true
    }
  }

  rule_group_reference_statement = {
    60 = {
      name = "AllowAllOptionsRequests"
      rule_group_arn = aws_wafv2_rule_group.waf_v2_options_rule_group.arn
      override_action = "none"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled = true
    }
  }

  ip_rate_based_rule = {
    name = "250RateLimit"
    limit = 250
    action = "block"
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled = true
  }

  visibility_config = {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled = true
  }
}

```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_default\_action | Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default. | `bool` | `true` | no |
| create\_logging\_configuration | Create logging configuration in order start logging from a WAFv2 Web ACL to Amazon Kinesis Data Firehose. | `bool` | `false` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources | `bool` | `true` | no |
| ip\_rate\_based\_rule | A rate-based rule tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>object({<br>    name = string<br>    limit = number<br>    action = string<br>    cloudwatch_metrics_enabled = bool<br>    sampled_requests_enabled = bool<br>  })</pre> | `null` | no |
| ip\_sets\_rule | A rule to detect web requests coming from particular IP addresses or address ranges. | <pre>map(object({<br>    name = string<br>    ip_set_arn = string<br>    action = string<br>    cloudwatch_metrics_enabled = bool<br>    sampled_requests_enabled = bool<br>  }))</pre> | `null` | no |
| managed\_rules | Object of AWS Managed WAFv2 rules. | <pre>map(object({<br>    managed_rule_name = string<br>    override_action = string<br>    cloudwatch_metrics_enabled = bool<br>    sampled_requests_enabled = bool<br>    vendor_name = string<br>    excluded_rules = list(string)<br>  }))</pre> | `null` | no |
| name | The name for the Web ACL | `string` | n/a | yes |
| redacted\_fields\_single\_header | The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported. | `list(string)` | `[]` | no |
| rule\_group\_reference\_statement | A rule statement used to run the rules that are defined in an WAFv2 Rule Group | <pre>map(object({<br>    name = string<br>    rule_group_arn = string<br>    override_action = string<br>    cloudwatch_metrics_enabled = bool<br>    sampled_requests_enabled = bool<br>  }))</pre> | `null` | no |
| tags | A map of tags (key-value pairs) passed to resources. | `map(string)` | `null` | no |
| visibility\_config | Visibility config for WAFv2 web acl | <pre>object({<br>    cloudwatch_metrics_enabled = bool<br>    sampled_requests_enabled = bool<br>  })</pre> | n/a | yes |
| waf\_v2\_logs\_bucket | Name for the s3 bucket that firehose logs are stored in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the WAF WebACL. |
| capacity | The web ACL capacity units (WCUs) currently being used by this web ACL. |
| id | The ID of the WAF WebACL |



