edge "ram_group_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      arn as from_id,
      policy ->> 'PolicyName' as to_id
    from
      alicloud_ram_group,
      jsonb_array_elements(attached_policy) as policy
    where
      arn = any($1);
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
      arn as from_id,
      policy_arn ->> 'PolicyName' as to_id
    from
      alicloud_ram_role,
      jsonb_array_elements(attached_policy) as policy_arn
    where
      arn = any($1);
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
      arn as from_id,
      policy ->> 'PolicyName' as to_id
    from
      alicloud_ram_user,
      jsonb_array_elements(attached_policy) as policy
    where
      arn = any($1);
  EOQ

  param "ram_user_arns" {}
}
