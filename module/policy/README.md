# S3 Bucket Policy (terraform-aws-mod-s3-bucket-policy)

## Policies

| Policy SID                      | Default | Required | Description                                                                               |
| ------------------------------- | ------- | -------- | ----------------------------------------------------------------------------------------- |
| DenyOutsidePrincipals           | on      | yes      | Ensures the bucket is at most open to org                                                 |
| DenyNonSecureTraffic            | on      | yes      | Must use https to communicate with bucket                                                 |
| DenyIncorrectEncryptionHeader   | on      | maybe    | Required if bucket is encrypted using aws:kms. This ensures the consist key type is used. |
| EnforceTLSv12orHigher           | on      | no       | Must use TLS 1.2 or higher                                                                |
| deny_wrong_encryption           | on      | no       | Enforce ecryption key header                                                              |
| OrgRead                         | off     | no       | Add policy to allow read from entire org                                                  |
| cloudfront_oai_access           | off     | no       | Add policy to read via Cloudfront OAI IAM Role. Must also pass in OAI IAM Role ARN        |
| AllowCloudFrontServicePrincipal | off     | no       | Add policy to read via Cloudfront Service. Must pass in Distribution ARN                  |
| cicd_access                     | Off     | no       | Add policy to allow access to our CICD Role                                       |
| account_root_access             | On      | yes      | Adds policy that delegates permission to IAM Role of the same account as bucket           |

## Resources and Modules
- [S3 Bucket Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy.html)
