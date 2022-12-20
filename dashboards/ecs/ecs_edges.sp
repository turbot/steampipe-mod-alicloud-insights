edge "ecs_disk_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.arn as from_id,
      k.arn as to_id
    from
      alicloud_ecs_disk as d
      left join alicloud_kms_key k on d.kms_key_id = k.key_id
    where
      d.arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}

edge "ecs_snapshot_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.arn as from_id,
      k.arn as to_id
    from
      alicloud_ecs_snapshot as s
      left join alicloud_kms_key k on s.kms_key_id = k.key_id
    where
      s.arn = any($1);
  EOQ

  param "ecs_snapshot_arns" {}
}