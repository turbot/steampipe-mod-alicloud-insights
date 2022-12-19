
edge "oss_bucket_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      arn as from_id,
      server_side_encryption ->> 'KMSMasterKeyID' as to_id
    from
      alicloud_oss_bucket
    where
      arn = any($1);
  EOQ

  param "oss_bucket_arns" {}
}
