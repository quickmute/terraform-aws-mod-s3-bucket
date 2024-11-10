resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.set_lifecycle_rule ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rule
    content {
      id = rule.value["id"]
      ## We allow either key status = Enabled or Disabled or use enabled=true or false. For backward compatibility (10/26/2022)
      status = lookup(rule.value, "status", (lookup(rule.value, "enabled", false) == true ? "Enabled" : "Disabled"))
      dynamic "filter" {
        # Filter can have ONLY one of following: prefix, object_size_greater, object_size_less, tag, and, empty
        for_each = lookup(lookup(rule.value, "filter", { empty = [{ prefix = null }] }), "empty", [lookup(rule.value, "filter", {})])
        #for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? lookup(rule.value, "prefix", null) == null ? [] : local.lifecyle_rule_template : [lookup(rule.value, "filter", {})]
        content {
          ## the same attributes here can exist inside "and" block too just NOT at the same time (10/26/2022)
          object_size_greater_than = lookup(filter.value, "object_size_greater_than", null)
          object_size_less_than    = lookup(filter.value, "object_size_less_than", null)
          prefix                   = lookup(filter.value, "prefix", null)
          dynamic "tag" {
            ## ONLY 1 tag allowed here! Remember it's tag here and tags below inside "and" block
            for_each = length(keys(lookup(filter.value, "tag", {}))) == 0 ? [] : [lookup(filter.value, "tag", {})]
            content {
              key   = tag.value["key"]
              value = tag.value["value"]
            }
          }
          dynamic "and" {
            # "and" have multiple of following: prefix, object_size_greater, object_size_less, tag, and, empty
            for_each = length(keys(lookup(filter.value, "and", {}))) == 0 ? [] : [lookup(filter.value, "and", {})]
            content {
              object_size_greater_than = lookup(and.value, "object_size_greater_than", null)
              object_size_less_than    = lookup(and.value, "object_size_less_than", null)
              prefix                   = lookup(and.value, "prefix", null)
              tags                     = lookup(and.value, "tags", {})
            }
          }
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = length(keys(lookup(rule.value, "abort_incomplete_multipart_upload", {}))) == 0 ? [] : [lookup(rule.value, "abort_incomplete_multipart_upload", {})]
        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]
        content {
          ##backward compatible to be able to use consistent noncurrent_days or old school days (10/26/2022)
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", lookup(noncurrent_version_expiration.value, "days", null))
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = length(lookup(rule.value, "noncurrent_version_transition", [])) == 0 ? [] : lookup(rule.value, "noncurrent_version_transition", [])
        content {
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "newer_noncurrent_versions", null)
          noncurrent_days           = lookup(noncurrent_version_transition.value, "noncurrent_days", null)
          storage_class             = lookup(noncurrent_version_transition.value, "storage_class", "INTELLIGENT_TIERING")
        }
      }

      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule.value, "expiration", {})]

        content {
          ## Added data and expired_object flag (10/26/2022)
          date = lookup(expiration.value, "date ", null)
          days = lookup(expiration.value, "days", null)
          # Use date and/or days OR expired_object_delete_marker, do not use below with either of above 
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)

        }
      }

      dynamic "transition" {
        for_each = length(lookup(rule.value, "transition", [])) == 0 ? [] : lookup(rule.value, "transition", [])

        content {
          date          = try(transition.value["date"], null)
          days          = try(transition.value["days"], null)
          storage_class = try(transition.value["storage_class"], "STANDARD_IA")
        }
      }
    }
  }
}
