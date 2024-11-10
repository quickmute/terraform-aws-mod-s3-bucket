## Outputs
output "bucket_policy" {
  description = "Bucket Policy JSON"
  value       = data.aws_iam_policy_document.bucket_policy_combined.json
}
