module "bucket_policy" {
  source  = "./module/policy"

  bucket_name        = aws_s3_bucket.this.id
  bucket_policy      = var.bucket_policy
  sse_algorithm      = var.sse_algorithm
  enforce_tls12      = var.enforce_tls12
  enforce_kms_header = var.enforce_kms_header
  allow_org_read     = var.allow_org_read
  allow_cicd_access  = var.allow_cicd_access
  tags               = local.tags
}
