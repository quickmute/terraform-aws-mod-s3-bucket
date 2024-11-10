resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  ## Set this to ensure we don't accidently set/unset versioning on wrong bucket
  ## It helps guard against mistakes
  expected_bucket_owner = local.account_num
  versioning_configuration {
    status = var.bucket_versioning ? "Enabled" : var.does_bucket_already_exist ? "Suspended" : "Disabled"
  }
}
