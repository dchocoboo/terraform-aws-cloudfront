# resource "aws_cloudwatch_log_group" "s3_logging" {
#   count = var.create_distribution && !var.logging_v2_config_s3.cloudwatch_log_group_arn ? 1 : 0
#   name  = var.logging_v2_config_s3.cloudwatch_log_group_name
#   tags  = var.tags
# }

locals {
  # Determine which logging destinations are enabled
  s3_logging_enabled         = var.logging_v2_config_s3.enabled
  cloudwatch_logging_enabled = var.logging_v2_config_cloudwatch_logs.enabled

  # Create delivery source if any logging is enabled
  any_logging_enabled = local.s3_logging_enabled || local.cloudwatch_logging_enabled

  logging_v2_config_s3_full_arn = var.logging_v2_config_s3.prefix != null ? "${var.logging_v2_config_s3.arn}/${var.logging_v2_config_s3.prefix}" : var.logging_v2_config_s3.arn

  # Create a hash of key attributes to force recreation when they change
  logging_v2_config_s3_key_hash = md5(jsonencode({
    destination_arn = local.logging_v2_config_s3_full_arn
    output_format   = var.logging_v2_config_s3.output_format
    name_prefix     = var.logging_v2_config_s3.name
  }))

  # CloudWatch Log Group name with default pattern
  cloudwatch_log_group_name = var.logging_v2_config_cloudwatch_logs.log_group_name != null ? var.logging_v2_config_cloudwatch_logs.log_group_name : (
    lookup(var.tags, "Name", null) != null ?
    "/aws/cloudfront/${var.tags["Name"]}-${aws_cloudfront_distribution.this[0].id}" :
    "/aws/cloudfront/${aws_cloudfront_distribution.this[0].id}"
  )

  # Create a hash for CloudWatch delivery destination key attributes
  logging_v2_config_cloudwatch_key_hash = md5(jsonencode({
    log_group_name    = local.cloudwatch_log_group_name
    output_format     = var.logging_v2_config_cloudwatch_logs.output_format
    name_prefix       = var.logging_v2_config_cloudwatch_logs.name
    retention_in_days = var.logging_v2_config_cloudwatch_logs.retention_in_days
    kms_key_id        = var.logging_v2_config_cloudwatch_logs.kms_key_id
  }))
}

# Single delivery source for CloudFront access logs
# This source can feed multiple destinations (S3, CloudWatch Logs, etc.)
resource "aws_cloudwatch_log_delivery_source" "cloudfront" {
  count        = var.create_distribution && local.any_logging_enabled ? 1 : 0
  name         = "cloudfront-${aws_cloudfront_distribution.this[0].id}"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this[0].arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "s3" {
  count = var.create_distribution && local.s3_logging_enabled ? 1 : 0

  # AWS CloudWatch Log Delivery Destination has API limitations that prevent in-place updates:
  # - ConflictException: "Tags can only be provided when a resource is being created, not updated"
  # - Changes to delivery_destination_configuration and output_format also require recreation
  # 
  # To work around this, we include a hash of key attributes in the resource name and tags.
  # When these attributes change, the hash changes, forcing Terraform to recreate the resource
  # instead of attempting an update that would fail with the AWS API.
  name = var.logging_v2_config_s3.name != null ? var.logging_v2_config_s3.name : "cloudfront-${aws_cloudfront_distribution.this[0].id}-s3-${substr(local.logging_v2_config_s3_key_hash, 0, 8)}"

  delivery_destination_configuration {
    destination_resource_arn = local.logging_v2_config_s3_full_arn
  }

  output_format = var.logging_v2_config_s3.output_format

  # Include the recreation hash in tags to force recreation when key attributes change
  # This prevents AWS API errors like: "Tags can only be provided when a resource is being created, not updated"
  tags = merge(var.tags, {
    terraform_recreation_hash = local.logging_v2_config_s3_key_hash
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_delivery" "s3" {
  count                    = var.create_distribution && local.s3_logging_enabled ? 1 : 0
  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3[0].arn

  s3_delivery_configuration {
    suffix_path = var.logging_v2_config_s3.suffix_path
  }

  field_delimiter = var.logging_v2_config_s3.output_format == "json" ? null : var.logging_v2_config_s3.output_format_field_delimiter

  tags = var.tags
}

# ---------------------------------
# CloudWatch Log Delivery to CloudWatch Log Group

resource "aws_cloudwatch_log_group" "cloudwatch_logs" {
  count                       = var.create_distribution && local.cloudwatch_logging_enabled ? 1 : 0
  name                        = local.cloudwatch_log_group_name
  retention_in_days           = var.logging_v2_config_cloudwatch_logs.retention_in_days
  kms_key_id                  = var.logging_v2_config_cloudwatch_logs.kms_key_id
  deletion_protection_enabled = var.logging_v2_config_cloudwatch_logs.deletion_protection_enabled
  tags                        = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "cloudwatch_logs" {
  count = var.create_distribution && local.cloudwatch_logging_enabled ? 1 : 0

  # AWS CloudWatch Log Delivery Destination has API limitations that prevent in-place updates:
  # - ConflictException: "Tags can only be provided when a resource is being created, not updated"
  # - Changes to delivery_destination_configuration and output_format also require recreation
  # 
  # To work around this, we include a hash of key attributes in the resource name and tags.
  # When these attributes change, the hash changes, forcing Terraform to recreate the resource
  # instead of attempting an update that would fail with the AWS API.
  name = var.logging_v2_config_cloudwatch_logs.name != null ? var.logging_v2_config_cloudwatch_logs.name : "cloudfront-${aws_cloudfront_distribution.this[0].id}-cloudwatch-logs-${substr(local.logging_v2_config_cloudwatch_key_hash, 0, 8)}"

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.cloudwatch_logs[0].arn
  }

  output_format = var.logging_v2_config_cloudwatch_logs.output_format

  # Include the recreation hash in tags to force recreation when key attributes change
  # This prevents AWS API errors like: "Tags can only be provided when a resource is being created, not updated"
  tags = merge(var.tags, {
    terraform_recreation_hash = local.logging_v2_config_cloudwatch_key_hash
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_delivery" "cloudwatch_logs" {
  count                    = var.create_distribution && local.cloudwatch_logging_enabled ? 1 : 0
  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.cloudwatch_logs[0].arn

  tags = var.tags
}
