dashboard "alicloud_ram_user_detail" {

  title         = "Alicloud RAM User Detail"
  documentation = file("./dashboards/ram/docs/ram_user_detail.md")

  tags = merge(local.ram_common_tags, {
    type = "Detail"
  })

  input "user_name" {
    title = "Select a user:"
    query = query.alicloud_ram_user_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.alicloud_ram_user_mfa_for_user
      args = {
        name = self.input.user_name.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ram_user_direct_attached_policy_count_for_user
      args = {
        name = self.input.user_name.value
      }
    }

  }

  container {

    container {

      width = 4

      table {
        title = "Overview"
        type  = "line"
        query = query.alicloud_ram_user_overview
        args = {
          name = self.input.user_name.value
        }
      }

    }

    container {

      width = 8

      table {
        title = "Access Keys"
        query = query.alicloud_ram_user_access_keys
        args = {
          name = self.input.user_name.value
        }
      }

      table {
        title = "MFA Devices"
        query = query.alicloud_ram_user_mfa_devices
        args = {
          name = self.input.user_name.value
        }
      }

    }

  }

  container {

    title = "Alicloud RAM User Policy Analysis"

    flow {
      type  = "sankey"
      title = "Attached Policies"
      query = query.alicloud_ram_user_manage_policies_sankey
      args = {
        name = self.input.user_name.value
      }

      category "alicloud_ram_group" {
        color = "ok"
      }
    }

    table {
      title = "Groups"
      width = 6
      query = query.alicloud_ram_groups_for_user
      args = {
        name = self.input.user_name.value
      }

      column "Name" {
        // cyclic dependency prevents use of url_path, hardcode for now
        href = "/alicloud_insights.dashboard.alicloud_ram_group_detail?input.group_title={{.'Name' | @uri}}"

      }
    }

    table {
      title = "Policies"
      width = 6
      query = query.alicloud_ram_all_policies_for_user
      args = {
        name = self.input.user_name.value
      }
    }

  }
}

query "alicloud_ram_user_input" {
  sql = <<-EOQ
    select
      title as label,
      name as value,
      json_build_object(
        'account_id', account_id
      ) as tags
    from
      alicloud_ram_user
    order by
      title;
  EOQ
}

query "alicloud_ram_user_mfa_for_user" {
  sql = <<-EOQ
    select
      case when mfa_enabled then 'Enabled' else 'Disabled' end as value,
      'MFA Status' as label,
      case when mfa_enabled then 'ok' else 'alert' end as type
    from
      alicloud_ram_user
    where
      name = $1
  EOQ

  param "name" {}
}

query "alicloud_ram_user_direct_attached_policy_count_for_user" {
  sql = <<-EOQ
    select
      coalesce(jsonb_array_length(attached_policy), 0) as value,
      'Direct Attached Policies' as label,
      case when coalesce(jsonb_array_length(attached_policy), 0) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_user
    where
     name = $1
  EOQ

  param "name" {}
}

query "alicloud_ram_user_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      create_date as "Create Date",
      update_date as "Last Modified Date",
      user_id as "User ID",
      account_id as "Account ID"
    from
      alicloud_ram_user
    where
      name = $1
  EOQ

  param "name" {}
}

query "alicloud_ram_user_access_keys" {
  sql = <<-EOQ
    select
      access_key_id  as "Access Key ID",
      a.status as "Status",
      a.create_date as "Create Date"
    from
      alicloud_ram_access_key as a left join alicloud_ram_user as u on u.name = a.user_name
    where
      u.name  = $1
  EOQ

  param "name" {}
}

query "alicloud_ram_user_mfa_devices" {
  sql = <<-EOQ
    select
      mfa_device_serial_number as "MFA Device Serial Number"
    from
      alicloud_ram_user
    where
      name  = $1
  EOQ

  param "name" {}
}

query "alicloud_ram_user_manage_policies_sankey" {
  sql = <<-EOQ

    with args as (
        select $1 as ram_user_aka
    )

    -- User
    select
      null as from_id,
      name as id,
      title,
      0 as depth,
      'alicloud_ram_user' as category
    from
      alicloud_ram_user
    where
      name in (select ram_user_aka from args)

    -- Groups
    union select
      u.name as from_id,
      g.name as id,
      user_groups ->> 'GroupName' as title,
      1 as depth,
      'alicloud_ram_group' as category
    from
      alicloud_ram_user as u,
      jsonb_array_elements(u.groups) as user_groups
      inner join alicloud_ram_group g on g.name = user_groups ->> 'GroupName'
    where
      u.name in (select ram_user_aka from args)

    -- Policies (attached to groups)
    union select
      g.name as from_id,
      p.title as id,
      p.title as title,
      2 as depth,
      'alicloud_ram_policy' as category
    from
      alicloud_ram_user as u,
      alicloud_ram_policy as p,
      jsonb_array_elements(u.groups) as user_groups
      inner join alicloud_ram_group g on g.name = user_groups ->> 'GroupName',
      jsonb_array_elements(g.attached_policy) as user_policy
    where
       user_policy ->> 'PolicyName' = p.title
       and u.name in (select ram_user_aka from args)

    -- Policies (attached to user)
    union select
      u.name as from_id,
      p.title as id,
      p.title as title,
      2 as depth,
      'alicloud_ram_policy' as category
    from
      alicloud_ram_user as u,
      jsonb_array_elements(u.attached_policy) as pol_arn,
      alicloud_ram_policy as p
    where
      pol_arn ->> 'PolicyName' = p.title
      and u.name in (select ram_user_aka from args)

  EOQ

  param "name" {}
}

query "alicloud_ram_groups_for_user" {
  sql = <<-EOQ
    select
      g ->> 'GroupName' as "Name",
      g ->> 'JoinDate' as "Join Date"
    from
      alicloud_ram_user as u,
      jsonb_array_elements(groups) as g
    where
      u.name = $1
  EOQ

  param "name" {}
}

query "alicloud_ram_all_policies_for_user" {
  sql = <<-EOQ

    -- Policies (attached to groups)
    select
      p.title as "Policy",
      'Group: ' || g.title as "Via"
    from
      alicloud_ram_user as u,
      alicloud_ram_policy as p,
      jsonb_array_elements(u.groups) as user_groups
      inner join alicloud_ram_group g on g.title = user_groups ->> 'GroupName',
      jsonb_array_elements(g.attached_policy) as group_policy
    where
      group_policy ->> 'PolicyName' = p.title
      and u.name = $1

    -- Policies (attached to user)
    union select
      p.title as "Policy",
      'Attached to User' as "Via"
    from
      alicloud_ram_user as u,
      jsonb_array_elements(u.attached_policy) as pol_arn,
      alicloud_ram_policy as p
    where
      pol_arn ->> 'PolicyName' = p.title
      and u.name = $1
  EOQ

  param "name" {}
}
