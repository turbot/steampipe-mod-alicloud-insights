
edge "oss_bucket_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.arn as from_id,
      k.arn as to_id
    from
      alicloud_oss_bucket as b
      left join alicloud_kms_key k on b.server_side_encryption ->> 'KMSMasterKeyID' = k.key_id
    where
      b.arn = any($1);
  EOQ

  param "oss_bucket_arns" {}
}
