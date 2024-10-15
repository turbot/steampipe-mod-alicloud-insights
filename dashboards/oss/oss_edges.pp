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

edge "oss_bucket_to_oss_bucket" {
  title = "logs to"

  sql = <<-EOQ
    select
      b.arn as from_id,
      lb.arn as to_id
    from
      alicloud_oss_bucket as lb,
      alicloud_oss_bucket as b
    where
      b.arn = any($1)
      and lb.name = b.logging ->> 'TargetBucket';
  EOQ

  param "oss_bucket_arns" {}
}
