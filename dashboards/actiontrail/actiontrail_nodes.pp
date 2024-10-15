node "actiontrail_trail" {
  category = category.actiontrail_trail

  sql = <<-EOQ
    select
      name as id,
      title as title,
      jsonb_build_object (
        'Name', name,
        'Creation Time', create_time,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_action_trail
    where
      name = any($1);
  EOQ

  param "action_trail_names" {}
}