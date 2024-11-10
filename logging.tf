resource "aws_s3_bucket_logging" "log" {
  count  = var.bucket_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_target_bucket == "" ? local.default_logging_bucket : var.logging_target_bucket
  target_prefix = var.logging_target_prefix == "" ? "${aws_s3_bucket.this.id}/" : var.logging_target_prefix
}
