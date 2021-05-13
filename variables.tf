variable "name" {
  type = string
  description = "Name of the firewall, will be prepended to all resources created"
}

variable "ip_blacklist" {
  type = set(string)
  description = "Set of IP addresses that are always blocked"
  default = []
}

variable "url_blacklist" {
  type = set(string)
  description = "Set of URLs that are always blocked (case insensitive)"
  default = []
}

variable "ip_whitelist" {
  type = set(string)
  description = "Set of IP addresses that bypass all blocking rules (other than the blacklist)"
  default = []
}

variable "url_whitelist" {
  type = set(string)
  description = "Set of URLs that bypass all blocking rules (other than the blacklist) (case insensitive)"
  default = []
}

variable "managed_rules" {
  type = list(string)
  description = "List of AWS managed rules to apply after all other rules have been matched"
  default = [
    "AWSManagedRulesCommonRuleSet",
    "AWSManagedRulesKnownBadInputsRuleSet",
    "AWSManagedRulesPHPRuleSet",
    "AWSManagedRulesAmazonIpReputationList",
    "AWSManagedRulesLinuxRuleSet",
    "AWSManagedRulesSQLiRuleSet"
  ]
}

