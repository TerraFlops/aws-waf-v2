resource "aws_wafv2_web_acl" "cloudfront_waf" {
  count = var.enabled == true ? 1 : 0

  name = var.name
  scope = "CLOUDFRONT"

  default_action {
    dynamic "allow" {
      for_each = var.allow_default_action ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.allow_default_action ? [] : [1]
      content {}
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      priority = rule.key
      name = rule.value["managed_rule_name"]

      override_action {
        dynamic "none" {
          for_each = rule.value["override_action"] == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value["override_action"] == "count" ? [1] : []
          content {}
        }
      }


      statement {
        managed_rule_group_statement {
          name = rule.value["managed_rule_name"]
          vendor_name = rule.value["vendor_name"]

          dynamic "excluded_rule" {
            for_each = rule.value["excluded_rules"]

            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        metric_name = "${rule.value["managed_rule_name"]}-rule-metric"
        cloudwatch_metrics_enabled = rule.value["cloudwatch_metrics_enabled"]
        sampled_requests_enabled = rule.value["sampled_requests_enabled"]
      }
    }
  }

  visibility_config {
    metric_name = "${var.name}-main-metric"
    cloudwatch_metrics_enabled = var.visibility_config["cloudwatch_metrics_enabled"]
    sampled_requests_enabled = var.visibility_config["sampled_requests_enabled"]
  }

  tags = var.tags
}

data "aws_iam_policy_document" "waf_firehose_logging_role_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = [
        "firehose.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "firehose_iam_role" {
  count = var.enabled == true && var.create_logging_configuration ? 1 : 0

  name = "${var.name}-firehouse-iam-role"

  assume_role_policy = data.aws_iam_policy_document.waf_firehose_logging_role_document.json

}

data "aws_iam_policy_document" "waf_firehose_logging_policy_document" {
  count = var.enabled == true && var.create_logging_configuration ? 1 : 0

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.bucket[0].arn}/*",
      aws_s3_bucket.bucket[0].arn
    ]
  }
  statement {
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::*:role/aws-service-role/wafv2.amazonaws.com/AWSServiceRoleForWAFV2Logging"
    ]
  }
}

resource "aws_iam_role_policy" "firehose_iam_policy" {
  count = var.enabled && var.create_logging_configuration ? 1 : 0

  name = "${var.name}-firehose-iam-policy"
  role = aws_iam_role.firehose_iam_role[0].id
  policy = data.aws_iam_policy_document.waf_firehose_logging_policy_document[0].json
}

resource "aws_s3_bucket" "bucket" {
  count = var.enabled == true && var.create_logging_configuration ? 1 : 0

  bucket = var.waf_v2_logs_bucket
  acl = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_waf_v2_stream" {
  count = var.enabled == true && var.create_logging_configuration ? 1 : 0

  name = "waf-logs-${var.name}"
  destination = "s3"

  s3_configuration {
    role_arn = aws_iam_role.firehose_iam_role[0].arn
    bucket_arn = aws_s3_bucket.bucket[0].arn
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_v2_logging" {
  count = var.enabled == true && var.create_logging_configuration ? 1 : 0

  log_destination_configs = [
    aws_kinesis_firehose_delivery_stream.firehose_waf_v2_stream[0].arn]
  resource_arn = aws_wafv2_web_acl.cloudfront_waf[0].arn


  dynamic "redacted_fields" {
    for_each = var.redacted_fields_single_header
    content {
      single_header {
        name = redacted_fields.value
      }
    }
  }
}
