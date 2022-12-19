edge "ecs_disk_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      arn as from_id,
      kms_key_id as to_id
    from
      alicloud_ecs_disk 
    where
      arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}

edge "ecs_snapshot_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      arn as from_id,
      kms_key_id as to_id
    from
      alicloud_ecs_snapshot 
    where
      arn = any($1);
  EOQ

  param "ecs_snapshot_arns" {}
}