# Insert output values here, if no outputs are defined delete this file

output "web_acl_arn" {
  value = aws_wafv2_web_acl.cloudfront_waf[*].arn
}

output "web_acl_id" {
  value = aws_wafv2_web_acl.cloudfront_waf[*].id
}

output "web_acl_name" {
  value = aws_wafv2_web_acl.cloudfront_waf[*].name
}
