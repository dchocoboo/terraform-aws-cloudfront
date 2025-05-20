# resource "aws_cloudwatch_log_group" "s3_logging" {
#   count = var.create_distribution && !var.logging_v2_config_s3.cloudwatch_log_group_arn ? 1 : 0
#   name  = var.logging_v2_config_s3.cloudwatch_log_group_name
#   tags  = var.tags
# }

resource "aws_cloudwatch_log_delivery_source" "s3" {
  count        = var.create_distribution && var.logging_v2_config_s3.enabled ? 1 : 0
  name         = var.logging_v2_config_s3.name
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this[0].arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "s3" {
  count = var.create_distribution && var.logging_v2_config_s3.enabled ? 1 : 0

  name = var.logging_v2_config_s3.name ? var.logging_v2_config_s3.name : "cloudfront-${aws_cloudfront_distribution.this[0].id}-s3"

  delivery_destination_configuration {
    destination_resource_arn = "${var.logging_v2_config_s3.bucket_arn}/${var.logging_v2_config_s3.bucket_prefix}"
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_delivery" "s3" {
  count                    = var.create_distribution && var.logging_v2_config_s3.enabled ? 1 : 0
  delivery_source_name     = aws_cloudwatch_log_delivery_source.s3[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3[0].arn

  s3_delivery_configuration {
    suffix_path = "/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
  }

  tags = var.tags
}
