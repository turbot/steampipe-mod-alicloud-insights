edge "actiontrail_trail_to_oss_bucket" {
  title = "logs to"

  sql = <<-EOQ
    select
      t.name as from_id,
      b.arn as to_id
    from
      alicloud_oss_bucket as b
      left join alicloud_action_trail t
        on b.name = t.oss_bucket_name
        and b.account_id = t.account_id
    where
      t.name = any($1);
  EOQ

  param "action_trail_names" {}
}

edge "actiontrail_trail_to_ram_role" {
  title = "assumes"

  sql = <<-EOQ
    select
      name as from_id,
      sls_write_role_arn as to_id
    from
      alicloud_action_trail
    where
      name = any($1);
  EOQ
  param "action_trail_names" {}
}