output "web_acl_arn" {
  value = aws_wafv2_web_acl.cloudfront_waf[0].arn
}

output "web_acl_id" {
  value = aws_wafv2_web_acl.cloudfront_waf[0].id
}

output "web_acl_name" {
  value = aws_wafv2_web_acl.cloudfront_waf[0].name
}
