output "id" {
  value       = var.create_bucket ? aws_s3_bucket.this[0].id : ""
  description = "The ID of the s3 bucket."
}

output "arn" {
  value       = var.create_bucket ? aws_s3_bucket.this[0].arn : ""
  description = "The ARN of the s3 bucket."
}

output "bucket_domain_name" {
  value       = var.create_bucket ? aws_s3_bucket.this[0].bucket_domain_name : ""
  description = "The domain name of the s3 bucket."
}

output "bucket_regional_domain_name" {
  value       = var.create_bucket ? aws_s3_bucket.this[0].bucket_regional_domain_name : ""
  description = "The regional domain name of the s3 bucket."
}

output "website_endpoint" {
  value       = var.create_bucket && var.website_hosting_bucket ? try(aws_s3_bucket_website_configuration.this[0].website_endpoint, "") : ""
  description = "The website endpoint of the s3 bucket."
}
