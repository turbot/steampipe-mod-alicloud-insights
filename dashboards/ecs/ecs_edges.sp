edge "ecs_disk_to_ecs_image" {
  title = "image"

  sql = <<-EOQ
    select
      d.arn as from_id,
      d.image_id as to_id
    from
      alicloud_ecs_disk as d
    where
      d.arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}

edge "ecs_disk_to_ecs_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
      select
        d.arn as from_id,
        s.arn as to_id
      from
        alicloud_ecs_snapshot s
        left join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
      where
        s.arn = any($1);
  EOQ

    param "ecs_snapshot_arns" {}
}

edge "ecs_snapshot_to_disk" {
  title = "disk"

  sql = <<-EOQ
      select
        s.arn as from_id,
        d.arn as to_id
      from
        alicloud_ecs_snapshot s
        left join alicloud_ecs_disk as d on s.snapshot_id = d.source_snapshot_id
      where
        s.arn = any($1);
  EOQ

    param "ecs_snapshot_arns" {}
}

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

edge "ecs_instance_to_ecs_disk" {
  title = "ecs_instance"

  sql = <<-EOQ
    select
      i.arn as from_id,
      d.arn as to_id
    from
      alicloud_ecs_instance i
      left join alicloud_ecs_disk as d on i.instance_id = d.instance_id
    where
      i.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
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