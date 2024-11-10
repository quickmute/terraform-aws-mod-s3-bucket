# Local definitions
locals {
  orgId      = data.aws_organizations_organization.current.id
  accountId  = data.aws_caller_identity.current.account_id
  regionName = data.aws_region.current.name

  ## generate arn of bucket from name
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"

  ## this is the default cicd role used to run pipeline
  cicd_role_arn = "arn:aws:iam::${local.accountId}:role/cicd-role"

  ## Add the current module info here
  tags = merge(var.tags,
    {
      "TFModule" = basename(path.module)
    }
  )
}
