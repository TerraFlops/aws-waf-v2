output "web_acl_arn" {
  value = aws_wafv2_web_acl.web_acl.arn
}

output "ip_whitelist_arn" {
  value = aws_wafv2_ip_set.ip_whitelist.arn
}

output "ip_blacklist_arn" {
  value = aws_wafv2_ip_set.ip_blacklist.arn
}
