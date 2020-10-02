variable "enabled" {
  type = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default = true
}

variable "name" {
  type = string
  description = "The name for the Web ACL"
}

variable "tags" {
  type = map(string)
  description = "A map of tags (key-value pairs) passed to resources."
  default = {}
}

variable "rules" {
  type = map(object({
    override_action = string
    cloudwatch_metrics_enabled = bool
    sampled_requests_enabled = bool
    vendor_name = string
    managed_rule_name = string
    excluded_rules = list(string)
  }))
  description = "List of WAF rules."
}

variable "visibility_config" {
  type = object({
    cloudwatch_metrics_enabled = bool
    sampled_requests_enabled = bool
  })
  description = "Visibility config for WAFv2 web acl"
}

variable "allow_default_action" {
  type = bool
  description = "Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default."
  default = true
}
variable "create_logging_configuration" {
  type = bool
  description = "Create logging configuration in order start logging from a WAFv2 Web ACL to Amazon Kinesis Data Firehose."
  default = false
}

variable "redacted_fields_single_header" {
  type = list(string)
  description = "The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported."
  default = []
}

variable "waf_v2_logs_bucket" {
  type = string
  description = "Name for the s3 bucket that firehose logs are stored in"
}
