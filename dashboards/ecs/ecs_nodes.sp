node "ecs_disk" {
  category = category.ecs_disk

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ID', disk_id,
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

node "ecs_image" {
  category = category.ecs_image

  sql = <<-EOQ
    select
      image_id as id,
      title as title,
      jsonb_build_object(
        'Image ID', image_id,
        'Image Family', image_family,
        'Status', status,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_image
    where
      image_id = any($1);
  EOQ

  param "ecs_image_ids" {}
}

node "ecs_instance" {
  category = category.ecs_instance

  sql = <<-EOQ
    select
      arn as id,
      title,
      jsonb_build_object(
        'Instance ID', instance_id,
        'Name', name,
        'ARN', arn,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_instance
    where
      arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
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