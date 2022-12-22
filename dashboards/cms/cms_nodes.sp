node "cms_monitor_host" {
  category = category.cms_monitor_host
  sql = <<-EOQ
    select
      cms.host_name as id,
      cms.title as title,
      jsonb_build_object(
        'Host Name', cms.host_name,
        'Instance Id', cms.instance_id,
        'Account Id', cms.account_id,
        'Region', cms.region
      ) as properties
    from
      alicloud_cms_monitor_host as cms,
      alicloud_ecs_instance as i
    where
      i.arn = any($1)
      and cms.instance_id = i.instance_id
      and cms.region = i.region
      and cms.account_id = i.account_id;
  EOQ

  param "ecs_instance_arns" {}
}
