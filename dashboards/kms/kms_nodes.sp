node "kms_key" {
  category = category.kms_key

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'Key Creator', creator,
        'Key Type', key_spec,
        'Creation Date', creation_date,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_kms_key
    where
      arn = any($1);
  EOQ

  param "kms_key_arns" {}
}