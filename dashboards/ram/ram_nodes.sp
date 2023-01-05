node "ram_access_key" {
  category = category.ram_access_key

  sql = <<-EOQ
    select
      a.access_key_id as id,
      a.title as title,
      jsonb_build_object(
        'Key Id', a.access_key_id,
        'Status', a.status,
        'Create Date', a.create_date,
        'Region', a.region
      ) as properties
    from
      alicloud_ram_access_key as a,
      alicloud_ram_user as u
    where
      u.name = a.user_name
      and u.region = a.region
      and u.account_id = a.account_id
      and u.arn  = any($1);
  EOQ

  param "ram_user_arns" {}
}

node "ram_group" {
  category = category.ram_group

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'Create Date', create_date,
        'Region', region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_ram_group
    where
      arn = any($1);
  EOQ

  param "ram_group_arns" {}
}

node "ram_policy" {
  category = category.ram_policy

  sql = <<-EOQ
    select
      akas::text as id,
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
      akas = any($1);
  EOQ

  param "ram_policy_akas" {}
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


node "ram_user" {
  category = category.ram_user

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'Name', name,
        'User ID', user_id,
        'Create Date', create_date,
        'MFA Enabled', mfa_enabled::text,
        'Account ID', account_id
      ) as properties
    from
      alicloud_ram_user
    where
      arn = any($1);
  EOQ

  param "ram_user_arns" {}
}
