resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = length(keys(var.object_lock_configuration)) == 0 ? 0 : 1

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = length(keys(lookup(var.object_lock_configuration, "rule", {}))) == 0 ? [] : [lookup(var.object_lock_configuration, "rule", {})]

    content {
      default_retention {
        mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
        days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
        years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
      }
    }
  }
}
