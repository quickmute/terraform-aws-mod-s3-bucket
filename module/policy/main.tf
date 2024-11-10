resource "aws_s3_bucket_policy" "policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.bucket_policy_combined.json
}

data "aws_iam_policy_document" "deny_outside_org" {
  statement {
    sid    = "DenyOutsidePrincipals"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:PrincipalOrgID"
      values   = [local.orgId]
    }
    condition {
      test     = "BoolIfExists"
      variable = "aws:PrincipalIsAWSService"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "deny_non_secure" {
  statement {
    sid    = "DenyNonSecureTraffic"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

## Only add if sse_algorithm = aws:kms
data "aws_iam_policy_document" "deny_wrong_encryption" {
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${local.bucket_arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

data "aws_iam_policy_document" "deny_older_tls" {
  statement {
    sid    = "EnforceTLSv12orHigher"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = [1.2]
    }
  }
}

data "aws_iam_policy_document" "org_read" {
  statement {
    sid    = "OrgRead"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [local.orgId]
    }
  }
}

data "aws_iam_policy_document" "cloudfront_oai" {
  statement {
    sid    = "cloudfront_oai_access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.cloudfront_oai_iam_arn]
    }
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
  }
}

data "aws_iam_policy_document" "cloudfront_oac" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${local.bucket_arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

data "aws_iam_policy_document" "cicd" {
  statement {
    sid    = "cicd_access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteObject*",
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
    ##Use this condition instead of principal because this role may not exist at time of this bucket deployment
    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [local.cicd_role_arn]
    }
  }
}

data "aws_iam_policy_document" "account_root_access" {
  statement {
    sid     = "account_root_access"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.accountId}:root"]
    }
    resources = [
      "${local.bucket_arn}/*",
      "${local.bucket_arn}"
    ]
  }
}

locals {
  allow_org_read_policy   = var.allow_org_read ? data.aws_iam_policy_document.org_read.json : ""
  enforce_tls12_policy    = var.enforce_tls12 ? data.aws_iam_policy_document.deny_older_tls.json : ""
  enforce_sse_algo_policy = var.sse_algorithm == "aws:kms" && var.enforce_kms_header == true ? data.aws_iam_policy_document.deny_wrong_encryption.json : ""
  cloudfront_oai_policy   = var.allow_cloudfront_oai_access ? data.aws_iam_policy_document.cloudfront_oai.json : ""
  cloudfront_oac_policy   = var.allow_cloudfront_oac_access ? data.aws_iam_policy_document.cloudfront_oac.json : ""
  cicd_policy             = var.allow_cicd_access ? data.aws_iam_policy_document.cicd.json : ""

  source_policy_documents = compact([
    data.aws_iam_policy_document.account_root_access.json,
    data.aws_iam_policy_document.deny_non_secure.json,
    data.aws_iam_policy_document.deny_outside_org.json,
    local.allow_org_read_policy,
    local.enforce_tls12_policy,
    local.enforce_sse_algo_policy,
    local.cloudfront_oai_policy,
    local.cloudfront_oac_policy,
    local.cicd_policy,
  ])
}

data "aws_iam_policy_document" "bucket_policy_combined" {
  override_policy_documents = [replace(var.bucket_policy, "$$$self_arn", local.bucket_arn)]
  source_policy_documents   = local.source_policy_documents
}
