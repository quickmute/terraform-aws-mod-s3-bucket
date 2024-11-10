output "bucket_arn" {
  description = "bucket_arn"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "bucket_domain_name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "bucket_regional_domain_name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "bucket_hosted_zone_id"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "bucket_id" {
  description = "bucket_id"
  value       = aws_s3_bucket.this.id
}

output "bucket_region" {
  description = "bucket_region"
  value       = aws_s3_bucket.this.region
}

output "bucket" {
  description = "bucket"
  value       = aws_s3_bucket.this
}

output "bucket_policy" {
  description = "bucket policy, if being set"
  value       = one(module.bucket_policy[*].bucket_policy)
}
