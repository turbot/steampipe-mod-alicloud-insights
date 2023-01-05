edge "ram_group_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      g.arn as from_id,
      p.akas::text as to_id
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

edge "ram_role_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      r.arn as from_id,
      p.akas::text as to_id
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
      p.akas::text as to_id
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
