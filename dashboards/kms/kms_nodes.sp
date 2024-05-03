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
      join unnest($1::text[]) as a on arn = a and account_id = split_part(a, ':', 4) and region = split_part(a, ':', 3);
  EOQ

  param "kms_key_arns" {}
}

node "kms_secret" {
  category = category.kms_secret

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'Secret Type', secret_type,
        'Encryption Key', encryption_key_id,
        'Creation Date', create_time,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_kms_secret
      join unnest($1::text[]) as a on arn = a and account_id = split_part(a, ':', 4) and region = split_part(a, ':', 3);
  EOQ

  param "kms_secret_arns" {}
}