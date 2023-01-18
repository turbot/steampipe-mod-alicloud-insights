edge "ram_group_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      g.arn as from_id,
      p.policy_name as to_id
    from
      alicloud_ram_group as g,
      alicloud_ram_policy as p,
      jsonb_array_elements(g.attached_policy) as policy
    where
      g.arn = any($1)
      and policy ->> 'PolicyName' = p.policy_name;
  EOQ

  param "ram_group_arns" {}

}

edge "ram_group_to_ram_user" {
  title = "has member"

  sql = <<-EOQ
    select
      g.arn as from_id,
      u.arn as to_id
    from
    alicloud_ram_user as u,
    alicloud_ram_group as g,
    jsonb_array_elements(u.groups) as ugrp
  where
    g.arn = any($1)
    and g.title = ugrp ->> 'GroupName';
  EOQ

  param "ram_group_arns" {}
}

edge "ram_policy_statement" {
  title = "statement"

  sql = <<-EOQ
    select
      distinct on (p.policy_name,i)
      p.policy_name as from_id,
      concat('statement:', i) as to_id
    from
      alicloud_ram_policy as p,
      jsonb_array_elements(p.policy_document_std -> 'Statement') with ordinality as t(stmt,i)
    where
      p.policy_name = any($1)
  EOQ

  param "ram_policy_names" {}
}

edge "ram_policy_statement_action" {
  sql = <<-EOQ
    select
      --distinct on (p.arn,action)
      concat('action:', action) as to_id,
      concat('statement:', i) as from_id,
      lower(t.stmt ->> 'Effect') as title,
      lower(t.stmt ->> 'Effect') as category
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_array_elements_text(t.stmt -> 'Action') as action
  EOQ

  param "ram_policy_stds" {}
}

edge "ram_policy_statement_condition" {
  title = "condition"

  sql = <<-EOQ
    select
      concat('statement:', i, ':condition:', condition.key) as to_id,
      concat('statement:', i) as from_id
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_each(t.stmt -> 'Condition') as condition
    where
      stmt -> 'Condition' <> 'null'
  EOQ

  param "ram_policy_stds" {}
}

edge "ram_policy_statement_condition_key" {
  title = "all of"

  sql = <<-EOQ
    select
      concat('statement:', i, ':condition:', condition.key, ':', condition_key.key  ) as to_id,
      concat('statement:', i, ':condition:', condition.key) as from_id
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_each(t.stmt -> 'Condition') as condition,
      jsonb_each(condition.value) as condition_key
    where
      stmt -> 'Condition' <> 'null'
  EOQ

  param "ram_policy_stds" {}
}

edge "ram_policy_statement_condition_key_value" {
  title = "any of"

  sql = <<-EOQ
    select
      concat('statement:', i, ':condition:', condition.key, ':', condition_key.key, ':', condition_value  ) as to_id,
      concat('statement:', i, ':condition:', condition.key, ':', condition_key.key  ) as from_id
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

edge "ram_policy_statement_notaction" {
  sql = <<-EOQ
    select
      --distinct on (p.arn,notaction)
      concat('action:', notaction) as to_id,
      concat('statement:', i) as from_id,
      concat(lower(t.stmt ->> 'Effect'), ' not action') as title,
      lower(t.stmt ->> 'Effect') as category
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i),
      jsonb_array_elements_text(t.stmt -> 'NotAction') as notaction
  EOQ

  param "ram_policy_stds" {}
}

edge "ram_policy_statement_notresource" {
  title = "not resource"

  sql = <<-EOQ
    select
      concat('action:', coalesce(action, notaction)) as from_id,
      notresource as to_id,
      lower(stmt ->> 'Effect') as category
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i)
      left join jsonb_array_elements_text(stmt -> 'Action') as action on true
      left join jsonb_array_elements_text(stmt -> 'NotAction') as notaction on true
      left join jsonb_array_elements_text(stmt -> 'NotResource') as notresource on true
  EOQ

  param "ram_policy_stds" {}
}

edge "ram_policy_statement_resource" {
  title = "resource"

  sql = <<-EOQ
    select
      concat('action:', coalesce(action, notaction)) as from_id,
      resource as to_id,
      lower(stmt ->> 'Effect') as category
    from
      jsonb_array_elements(($1 :: jsonb) ->  'Statement') with ordinality as t(stmt,i)
      left join jsonb_array_elements_text(stmt -> 'Action') as action on true
      left join jsonb_array_elements_text(stmt -> 'NotAction') as notaction on true
      left join jsonb_array_elements_text(stmt -> 'Resource') as resource on true
  EOQ

  param "ram_policy_stds" {}
}

edge "ram_role_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      r.arn as from_id,
      p.policy_name as to_id
    from
      alicloud_ram_role as r,
      alicloud_ram_policy as p,
      jsonb_array_elements(r.attached_policy) as policy
    where
      r.arn = any($1)
      and policy ->> 'PolicyName' = p.policy_name;
  EOQ

  param "ram_role_arns" {}
}

edge "ram_user_to_ram_access_key" {
  title = "access key"

  sql = <<-EOQ
    select
      u.arn as from_id,
      a.access_key_id as to_id
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

edge "ram_user_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      u.arn as from_id,
      p.policy_name as to_id
    from
      alicloud_ram_user as u,
      alicloud_ram_policy as p,
      jsonb_array_elements(u.attached_policy) as policy
    where
      u.arn = any($1)
      and policy ->> 'PolicyName' = p.policy_name;
  EOQ

  param "ram_user_arns" {}
}
