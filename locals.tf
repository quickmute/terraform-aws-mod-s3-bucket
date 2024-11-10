locals {
  account_num   = data.aws_caller_identity.current.account_id
  region        = data.aws_region.current.name
  org_id        = data.aws_organizations_organization.current.id
  bucket_prefix = var.add_prefix ? join("-", [local.account_num, local.region]) : ""
  ## bucket max is 63 characters
  ## bucket minimum length is 3
  bucket_meat_max = 63 - length(local.bucket_prefix)
  ## if someone tries to use too long of a name in addition to prefix, it'll trim it for you, 
  ## however this'll probably mess up any predefined policies done outside of this module
  ## the user should pay attention to the end resulting bucket name
  bucket_meat       = length(var.bucket_name) > local.bucket_meat_max ? (substr(var.bucket_name, 0, local.bucket_meat_max - 1)) : var.bucket_name
  bucket_name       = join("-", compact([local.bucket_prefix, local.bucket_meat]))
  replication_rules = lookup(var.replication_configuration, "rules", [])
  ## This bucket ONLY exists if this account was baselined. Else be sure to pass in your own logging bucket
  default_logging_bucket = "${local.account_num}-${local.region}-s3-access-logging"
  #don't use common_tags directly, use local.tags everywhere within this module
  tags = merge(var.tags,
    {
      "TFModule" = basename(path.module)
    }
  )
}
