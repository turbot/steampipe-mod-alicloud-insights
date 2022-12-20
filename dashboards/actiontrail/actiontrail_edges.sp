edge "actiontrail_trail_to_oss_bucket" {
  title = "logs to"

  sql = <<-EOQ
    select
      t.name as from_id,
      b.arn as to_id
    from
      alicloud_oss_bucket as b
      left join alicloud_action_trail t on b.name = t.oss_bucket_name
    where
      t.name = any($1);
  EOQ

  param "action_trail_names" {}
}