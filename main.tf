resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  # Use force destroy with EXTEME CARE!  There is no "undo"
  force_destroy = var.force_destroy

  tags = local.tags
}

####################################################################################
## S3 Developer Guide
## https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
####################################################################################
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
