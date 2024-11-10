variable "tags" {
  type        = map(string)
  description = "(Optional) New tags, get rid of default here and common_tags when we migrated people over. It should be mandatory, but we didn't want to break anyone. Sentinel Checked."
  default     = {}
  ## kept above default to be backward compatible, suggest removing it when you move to version 5 of this module
}

variable "bucket_name" {
  type        = string
  description = "(Required) Bring your bucket name. Set 'add_prefix' variable to TRUE to conform to our naming standard and omit the Account ID and Region from your name. We'll add that for you. We leave this optional for backward compatibility."

  validation {
    condition     = length(var.bucket_name) > 3
    error_message = "Bucket Name must be more than 3 characters."
  }
}

variable "add_prefix" {
  type        = bool
  default     = false
  description = "(Optional) To add or not to add our predefined prefix: AccountNumber-RegionName. Please set this to True for all NEW buckets unless your use case does not support."
}

variable "bucket_policy" {
  type        = string
  default     = "{}"
  description = "(Optional) this a json policy doc within EOF tags."
}

variable "bucket_versioning" {
  type        = bool
  default     = true
  description = "(Optional) this will set versioning enabled by default."
}

variable "bucket_key_enabled" {
  type        = bool
  description = "(Optional) Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  default     = false
}

variable "does_bucket_already_exist" {
  type        = bool
  description = "(Optional) For existing S3 buckets, versioning enabled = false is synonymous to Suspended. So we need to override `disabled` with `Suspended` by setting this variable to true."
  default     = false
}

variable "set_lifecycle_rule" {
  description = "(Optional) Whether or not to set lifecycle, if you don't say yes here, we'll ignore the lifecycle rule."
  type        = bool
  default     = true
}

variable "lifecycle_rule" {
  description = "(Optional) List of maps containing configuration of object lifecycle management."
  type        = any
  default = [
    {
      id = "default"
      filter = {
        prefix = ""
      }
      status = "Enabled"
      transition = [
        {
          days          = 180
          storage_class = "STANDARD_IA"
        },
        {
          days          = 365
          storage_class = "GLACIER_IR"
        },
      ]
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]
}

variable "sse_algorithm" {
  type        = string
  description = "(Optional) The server-side encryption algorithm to use. Valid values are 'AES256' (Default S3 encryption) and 'aws:kms' (either aws managed s3 default kms or customer created one). If using AES256, you must set kms_master_key_id = null and bucket_key_enabled = false."
  default     = "aws:kms"
}

variable "kms_master_key_id" {
  type        = string
  description = "(Optional) The AWS KMS master key ID used for the SSE-KMS encryption. Leave as null unless you brought your own KMS key."
  default     = null
}

variable "object_lock_configuration" {
  type        = any
  default     = {}
  description = "(Optional) Configuration if object lock is required."
}

variable "replication_configuration" {
  description = "(Optional) Map containing configuration of s3 bucket replication rules."
  type        = any
  default     = {}
}

variable "force_destroy" {
  type        = bool
  description = "(Optional, Default:false) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "bucket_logging_enabled" {
  type        = bool
  description = "(Optional) Whether bucket logging should be enabled or not -- default behavior is to enable logging (value of 'true')."
  default     = true
}

variable "logging_target_prefix" {
  description = "(Optional) Prefix within logging bucket.  When unassigned or blank, it will (create and) use a default directory path in the bucket.  This only applies when 'bucket_logging_enabled' is unassigned or set to true."
  default     = ""
  type        = string
}

variable "logging_target_bucket" {
  description = "(Optional) ID of the bucket and Prefix.  When unassigned or blank, it will use the default logging bucket in the account.  This only applies when 'bucket_logging_enabled' is unassigned or set to true."
  default     = ""
  type        = string
}

variable "enforce_tls12" {
  type        = bool
  description = "(Optional) Set to false if your application cannot support using TLS 1.2 or higher to access this bucket"
  default     = true
}

variable "enforce_kms_header" {
  type        = bool
  description = "(Optional) Set to false if your application cannot support supplying a KMS key to access this bucket. Defaults to true."
  default     = true
}

variable "allow_org_read" {
  type        = bool
  description = "(Optional) Set to true, if this bucket should be readable from all accounts. Useful for shared bucket"
  default     = false
}

variable "cloudfront_oai_iam_arn" {
  type        = string
  description = "(Optional) But required when hosting website behind cloudfront. ARN of IAM Role of aws_cloudfront_origin_access_identity"
  default     = ""
}

variable "allow_cicd_access" {
  type        = bool
  description = "(Optional) Attach policy for CICD access."
  default     = false
}
