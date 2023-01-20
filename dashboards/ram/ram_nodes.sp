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

node "ram_policy_statement" {
  category = category.ram_policy_statement

  sql = <<-EOQ
    select
      concat('statement:', i) as id,
      coalesce (
        t.stmt ->> 'Sid',
        concat('[', i::text, ']')
        ) as title
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i)
  EOQ

  param "ram_policy_stds" {}
}

node "ram_policy_statement_action_notaction" {
  category = category.ram_policy_action

  sql = <<-EOQ
    select
      concat('action:', action) as id,
      case when action = '*' then action || ' [All Actions]' else action end as title
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_array_elements_text(coalesce(t.stmt -> 'Action','[]'::jsonb) || coalesce(t.stmt -> 'NotAction','[]'::jsonb)) as action
  EOQ

  param "ram_policy_stds" {}
}

node "ram_policy_statement_condition" {
  category = category.ram_policy_condition

  sql = <<-EOQ
    select
      condition.key as title,
      concat('statement:', i, ':condition:', condition.key  ) as id,
      condition.value as properties
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_each(t.stmt -> 'Condition') as condition
    where
      stmt -> 'Condition' <> 'null'
  EOQ

  param "ram_policy_stds" {}
}

node "ram_policy_statement_condition_key" {
  category = category.ram_policy_condition_key

  sql = <<-EOQ
    select
      condition_key.key as title,
      concat('statement:', i, ':condition:', condition.key, ':', condition_key.key  ) as id,
      condition_key.value as properties
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_each(t.stmt -> 'Condition') as condition,
      jsonb_each(condition.value) as condition_key
    where
      stmt -> 'Condition' <> 'null'
  EOQ

  param "ram_policy_stds" {}
}

node "ram_policy_statement_condition_key_value" {
  category = category.ram_policy_condition_value

  sql = <<-EOQ
    select
      condition_value as title,
      concat('statement:', i, ':condition:', condition.key, ':', condition_key.key, ':', condition_value  ) as id
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_each(t.stmt -> 'Condition') as condition,
      jsonb_each(condition.value) as condition_key,
      jsonb_array_elements_text(condition_key.value) as condition_value
    where
      stmt -> 'Condition' <> 'null'
  EOQ

  param "ram_policy_stds" {}
}

node "ram_policy_statement_resource_notresource" {
  category = category.ram_policy_resource

  sql = <<-EOQ
    select
      resource as id,
      case when resource = '*' then resource || ' [All Resources]' else resource end as title
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_array_elements_text(coalesce(t.stmt -> 'Action','[]'::jsonb) || coalesce(t.stmt -> 'NotAction','[]'::jsonb)) as action,
      jsonb_array_elements_text(coalesce(t.stmt -> 'Resource','[]'::jsonb) || coalesce(t.stmt -> 'NotResource','[]'::jsonb)) as resource
  EOQ

  param "ram_policy_stds" {}
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