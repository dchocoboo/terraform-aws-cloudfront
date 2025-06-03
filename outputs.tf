output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = try(aws_cloudfront_distribution.this[0].id, "")
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = try(aws_cloudfront_distribution.this[0].arn, "")
}

output "cloudfront_distribution_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration."
  value       = try(aws_cloudfront_distribution.this[0].caller_reference, "")
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = try(aws_cloudfront_distribution.this[0].status, "")
}

output "cloudfront_distribution_trusted_signers" {
  description = "List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs"
  value       = try(aws_cloudfront_distribution.this[0].trusted_signers, "")
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = try(aws_cloudfront_distribution.this[0].domain_name, "")
}

output "cloudfront_distribution_last_modified_time" {
  description = "The date and time the distribution was last modified."
  value       = try(aws_cloudfront_distribution.this[0].last_modified_time, "")
}

output "cloudfront_distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress."
  value       = try(aws_cloudfront_distribution.this[0].in_progress_validation_batches, "")
}

output "cloudfront_distribution_etag" {
  description = "The current version of the distribution's information."
  value       = try(aws_cloudfront_distribution.this[0].etag, "")
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to."
  value       = try(aws_cloudfront_distribution.this[0].hosted_zone_id, "")
}

output "cloudfront_origin_access_identities" {
  description = "The origin access identities created"
  value       = { for k, v in aws_cloudfront_origin_access_identity.this : k => v if local.create_origin_access_identity }
}

output "cloudfront_origin_access_identity_ids" {
  description = "The IDS of the origin access identities created"
  value       = [for v in aws_cloudfront_origin_access_identity.this : v.id if local.create_origin_access_identity]
}

output "cloudfront_origin_access_identity_iam_arns" {
  description = "The IAM arns of the origin access identities created"
  value       = [for v in aws_cloudfront_origin_access_identity.this : v.iam_arn if local.create_origin_access_identity]
}

output "cloudfront_monitoring_subscription_id" {
  description = " The ID of the CloudFront monitoring subscription, which corresponds to the `distribution_id`."
  value       = try(aws_cloudfront_monitoring_subscription.this[0].id, "")
}

output "cloudfront_distribution_tags" {
  description = "Tags of the distribution's"
  value       = try(aws_cloudfront_distribution.this[0].tags_all, "")
}

output "cloudfront_origin_access_controls" {
  description = "The origin access controls created"
  value       = local.create_origin_access_control ? { for k, v in aws_cloudfront_origin_access_control.this : k => v } : {}
}

output "cloudfront_origin_access_controls_ids" {
  description = "The IDS of the origin access identities created"
  value       = local.create_origin_access_control ? [for v in aws_cloudfront_origin_access_control.this : v.id] : []
}

output "cloudfront_vpc_origin_ids" {
  description = "The IDS of the VPC origin created"
  value       = local.create_vpc_origin ? [for v in aws_cloudfront_vpc_origin.this : v.id] : []
}

# CloudWatch Log Delivery outputs
output "cloudwatch_log_delivery_source_name" {
  description = "The name of the CloudWatch log delivery source for CloudFront"
  value       = try(aws_cloudwatch_log_delivery_source.cloudfront[0].name, "")
}

output "cloudwatch_log_delivery_source_arn" {
  description = "The ARN of the CloudWatch log delivery source for CloudFront"
  value       = try(aws_cloudwatch_log_delivery_source.cloudfront[0].arn, "")
}

output "cloudwatch_log_delivery_destination_s3_name" {
  description = "The name of the CloudWatch log delivery destination for S3"
  value       = try(aws_cloudwatch_log_delivery_destination.s3[0].name, "")
}

output "cloudwatch_log_delivery_destination_s3_arn" {
  description = "The ARN of the CloudWatch log delivery destination for S3"
  value       = try(aws_cloudwatch_log_delivery_destination.s3[0].arn, "")
}

output "cloudwatch_log_delivery_s3_id" {
  description = "The ID of the CloudWatch log delivery for S3"
  value       = try(aws_cloudwatch_log_delivery.s3[0].id, "")
}

# CloudWatch Log Delivery CloudWatch Log Group outputs  
output "cloudwatch_log_group_cloudwatch_logs_name" {
  description = "The name of the CloudWatch log group for CloudFront logging"
  value       = try(aws_cloudwatch_log_group.cloudwatch_logs[0].name, "")
}

output "cloudwatch_log_group_cloudwatch_logs_arn" {
  description = "The ARN of the CloudWatch log group for CloudFront logging"
  value       = try(aws_cloudwatch_log_group.cloudwatch_logs[0].arn, "")
}

output "cloudwatch_log_delivery_destination_cloudwatch_logs_name" {
  description = "The name of the CloudWatch log delivery destination for CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_delivery_destination.cloudwatch_logs[0].name, "")
}

output "cloudwatch_log_delivery_destination_cloudwatch_logs_arn" {
  description = "The ARN of the CloudWatch log delivery destination for CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_delivery_destination.cloudwatch_logs[0].arn, "")
}

output "cloudwatch_log_delivery_cloudwatch_logs_id" {
  description = "The ID of the CloudWatch log delivery for CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_delivery.cloudwatch_logs[0].id, "")
}
