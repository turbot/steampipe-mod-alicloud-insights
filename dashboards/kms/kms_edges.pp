edge "kms_secret_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.arn as from_id,
      k.arn as to_id
    from
      alicloud_kms_secret as s
      join alicloud_kms_key k on s.encryption_key_id = k.key_id
      join unnest($1::text[]) as a on k.arn = a and k.account_id = split_part(a, ':', 4) and k.region = split_part(a, ':', 3);
  EOQ

  param "kms_secret_arns" {}
}