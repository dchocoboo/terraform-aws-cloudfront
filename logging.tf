# resource "aws_cloudwatch_log_group" "s3_logging" {
#   count = var.create_distribution && !var.logging_v2_config_s3.cloudwatch_log_group_arn ? 1 : 0
#   name  = var.logging_v2_config_s3.cloudwatch_log_group_name
#   tags  = var.tags
# }

locals {
  logging_v2_config_s3_full_arn = var.logging_v2_config_s3.prefix != null ? "${var.logging_v2_config_s3.arn}/${var.logging_v2_config_s3.prefix}" : var.logging_v2_config_s3.arn
}

resource "aws_cloudwatch_log_delivery_source" "s3" {
  count        = var.create_distribution && var.logging_v2_config_s3.enabled ? 1 : 0
  name         = var.logging_v2_config_s3.name != null ? var.logging_v2_config_s3.name : "cloudfront-${aws_cloudfront_distribution.this[0].id}-s3"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this[0].arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "s3" {
  count = var.create_distribution && var.logging_v2_config_s3.enabled ? 1 : 0

  name = var.logging_v2_config_s3.name != null ? var.logging_v2_config_s3.name : "cloudfront-${aws_cloudfront_distribution.this[0].id}-s3"

  delivery_destination_configuration {
    destination_resource_arn = local.logging_v2_config_s3_full_arn
  }

  output_format = var.logging_v2_config_s3.output_format

  tags = var.tags
}

resource "aws_cloudwatch_log_delivery" "s3" {
  count                    = var.create_distribution && var.logging_v2_config_s3.enabled ? 1 : 0
  delivery_source_name     = aws_cloudwatch_log_delivery_source.s3[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3[0].arn

  s3_delivery_configuration {
    suffix_path = "/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
  }

  field_delimiter = var.logging_v2_config_s3.output_format == "json" ? null : var.logging_v2_config_s3.output_format_field_delimiter

  tags = var.tags
}

