
node "ram_policy" {
  category = category.ram_policy

  sql = <<-EOQ
    select
      policy_name as id,
      title as title,
      jsonb_build_object(
        'Policy Name', policy_name,
        'Policy Type', policy_type,
        'Create Date', create_date,
        'Region', region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_ram_policy
    where
      policy_name = any($1);
  EOQ

  param "ram_policy_names" {}
}

node "ram_role" {
  category = category.ram_role

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'Name',name,
        'Create Date', create_date,
        'Max Session Duration', max_session_duration,
        'Region',region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_ram_role
    where
      arn = any($1);
  EOQ

  param "ram_role_arns" {}
}
