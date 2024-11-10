variable "bucket_name" {
  description = "(Required) Name of bucket"
  type        = string
}

variable "bucket_policy" {
  type        = string
  default     = "{}"
  description = "(Optional) this a json policy doc within EOF tags."
}

variable "sse_algorithm" {
  type        = string
  description = "(Optional) Which encryption is being used. aws:kms or AES256"
  default     = "aws:kms"
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

variable "allow_cloudfront_oai_access" {
  type        = bool
  description = "(Optional) When accessing from Cloudfront using OAI identity."
  default     = false
}

variable "cloudfront_oai_iam_arn" {
  type        = string
  description = "(Optional) But required when allow_cloudfront_oai_access is set."
  default     = ""
}

variable "allow_cloudfront_oac_access" {
  type        = bool
  description = "(Optional) When accessing from Cloudfront using OAC."
  default     = false
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "(Optional) But required when allow_cloudfront_oac_access is set."
  default     = ""
}

variable "allow_cicd_access" {
  type        = bool
  description = "(Optional) Attach policy for CICD pipeline access."
  default     = false
}

variable "tags" {
  description = "(Required) Tags"
  type        = map(string)
}
