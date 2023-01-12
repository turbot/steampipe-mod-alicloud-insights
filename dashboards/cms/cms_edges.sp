edge "cms_monitor_host_to_ecs_instance" {
  title = "instance"

  sql = <<-EOQ
    select
      cms.akas::text as from_id,
      i.arn as to_id
    from
      alicloud_ecs_instance i
      join alicloud_cms_monitor_host as cms on cms.instance_id = i.instance_id
    where
      i.arn = any($1)
      and cms.region = i.region
      and cms.account_id = i.account_id;
  EOQ

  param "ecs_instance_arns" {}
}