edge "kms_secret_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.arn as from_id,
      k.arn as to_id
    from
      alicloud_kms_secret as s
      left join alicloud_kms_key k on s.encryption_key_id = k.key_id
    where
      s.arn = any($1);
  EOQ

  param "kms_secret_arns" {}
}