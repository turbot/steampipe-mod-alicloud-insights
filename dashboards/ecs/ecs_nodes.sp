node "ecs_disk" {
  category = category.ecs_disk

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ID', volume_id,
        'ARN', arn,
        'Size', size,
        'Account ID', account_id,
        'Region', region,
        'KMS Key ID', kms_key_id
      ) as properties
    from
      alicloud_ecs_disk
    where
      arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}
node "ecs_snapshot" {
  category = category.ecs_snapshot

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ID', snapshot_id,
        'ARN', arn,
        'Start Time', start_time,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_snapshot
    where
      arn = any($1);
  EOQ

  param "ecs_snapshot_arns" {}
}