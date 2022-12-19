node "oss_bucket" {
  category = category.oss_bucket

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ARN', arn,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_oss_bucket
    where
      arn = any($1);
  EOQ

  param "oss_bucket_arns" {}
}