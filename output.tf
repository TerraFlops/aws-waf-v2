output "arn" {
  value = aws_wafv2_web_acl.cloudfront_waf[0].arn
  description = " The ARN of the WAF WebACL."
}

output "id" {
  value = aws_wafv2_web_acl.cloudfront_waf[0].id
  description = "The ID of the WAF WebACL"
}

output "capacity" {
  value = aws_wafv2_web_acl.cloudfront_waf[0].name
  description = "The web ACL capacity units (WCUs) currently being used by this web ACL."
}
