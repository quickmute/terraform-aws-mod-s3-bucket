resource "aws_s3_bucket_replication_configuration" "this" {
  count = length(local.replication_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id
  role   = lookup(var.replication_configuration, "role", null)

  dynamic "rule" {
    for_each = local.replication_rules

    content {
      id       = lookup(rule.value, "id", null)
      priority = lookup(rule.value, "priority", 0)
      status   = lookup(rule.value, "status", "Disabled")

      #This argument is only valid with V2 replication configurations (i.e. when filter is used)
      dynamic "delete_marker_replication" {
        for_each = length(keys(lookup(rule.value, "delete_marker_replication", {}))) == 0 ? [] : [lookup(rule.value, "delete_marker_replication", {})]
        content {
          status = lookup(delete_marker_replication.value, "status", "Disabled")
        }
      }

      # Max 1 block - filter
      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? [] : [lookup(rule.value, "filter", {})]

        content {
          # forcing v2 schema by throwing the rules.prefix value into the v2 "filter" block
          prefix = lookup(filter.value, "prefix", lookup(rule.value, "prefix", null))

          dynamic "tag" {
            for_each = length(keys(lookup(filter.value, "tag", {}))) == 0 ? [] : [lookup(filter.value, "tag", {})]
            content {
              key   = tag.value["key"]
              value = tag.value["value"]
            }
          }
        }
      }

      # Max 1 block - source_selection_criteria
      dynamic "source_selection_criteria" {
        for_each = length(keys(lookup(rule.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rule.value, "source_selection_criteria", {})]

        content {
          # Max 1 block - sse_kms_encrypted_objects
          dynamic "sse_kms_encrypted_objects" {
            for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

            content {
              status = lookup(sse_kms_encrypted_objects.value, "status", "Disabled")
            }
          }
        }
      }

      # Max 1 block - destination
      dynamic "destination" {
        for_each = length(keys(lookup(rule.value, "destination", {}))) == 0 ? [] : [lookup(rule.value, "destination", {})]

        content {
          bucket        = lookup(destination.value, "bucket", null)
          storage_class = lookup(destination.value, "storage_class", null)
          account       = lookup(destination.value, "account", null)

          dynamic "access_control_translation" {
            for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

            content {
              owner = lookup(access_control_translation.value, "owner", null)
            }
          }

          dynamic "encryption_configuration" {
            for_each = length(keys(lookup(destination.value, "encryption_configuration", {}))) == 0 ? [] : [lookup(destination.value, "encryption_configuration", {})]

            content {
              replica_kms_key_id = lookup(encryption_configuration.value, "replica_kms_key_id", null)
            }
          }

          dynamic "metrics" {
            for_each = length(keys(lookup(destination.value, "metrics", {}))) == 0 ? [] : [lookup(destination.value, "metrics", {})]
            content {
              status = lookup(metrics.value, "status", "Disabled")
              dynamic "event_threshold" {
                for_each = length(keys(lookup(metrics.value, "event_threshold", {}))) == 0 ? [] : [lookup(metrics.value, "event_threshold", {})]
                content {
                  minutes = lookup(event_threshold.value, "minutes", 15)
                }
              }
            }
          }
          dynamic "replication_time" {
            for_each = length(keys(lookup(destination.value, "replication_time", {}))) == 0 ? [] : [lookup(destination.value, "replication_time", {})]
            content {
              status = lookup(replication_time.value, "status", "Disabled")
              dynamic "time" {
                for_each = length(keys(lookup(replication_time.value, "time", {}))) == 0 ? [] : [lookup(replication_time.value, "time", {})]
                content {
                  minutes = lookup(time.value, "minutes", 15)
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}
