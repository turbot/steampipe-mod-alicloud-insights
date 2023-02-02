dashboard "ram_user_detail" {

  title         = "AliCloud RAM User Detail"
  documentation = file("./dashboards/ram/docs/ram_user_detail.md")

  tags = merge(local.ram_common_tags, {
    type = "Detail"
  })

  input "user_arn" {
    title = "Select a user:"
    query = query.ram_user_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.ram_user_mfa_for_user
      args  = [self.input.user_arn.value]
    }

    card {
      width = 3
      query = query.ram_user_direct_attached_policy_count_for_user
      args  = [self.input.user_arn.value]
    }

  }

  with "ram_groups_for_ram_user" {
    query = query.ram_groups_for_ram_user
    args  = [self.input.user_arn.value]
  }

  with "ram_policies_for_ram_user" {
    query = query.ram_policies_for_ram_user
    args  = [self.input.user_arn.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.ram_group
        args = {
          ram_group_arns = with.ram_groups_for_ram_user.rows[*].group_arn
        }
      }

      node {
        base = node.ram_policy
        args = {
          ram_policy_names = with.ram_policies_for_ram_user.rows[*].policy_name
        }
      }

      node {
        base = node.ram_user
        args = {
          ram_user_arns = [self.input.user_arn.value]
        }
      }

      node {
        base = node.ram_access_key
        args = {
          ram_user_arns = [self.input.user_arn.value]
        }
      }

      edge {
        base = edge.ram_group_to_ram_user
        args = {
          ram_group_arns = with.ram_groups_for_ram_user.rows[*].group_arn
        }
      }

      edge {
        base = edge.ram_user_to_ram_access_key
        args = {
          ram_user_arns = [self.input.user_arn.value]
        }
      }

      edge {
        base = edge.ram_user_to_ram_policy
        args = {
          ram_user_arns = [self.input.user_arn.value]
        }
      }

    }
  }

  container {

    container {

      width = 4

      table {
        title = "Overview"
        type  = "line"
        query = query.ram_user_overview
        args  = [self.input.user_arn.value]
      }

    }

    container {

      width = 8

      table {
        title = "Access Keys"
        query = query.ram_user_access_keys
        args  = [self.input.user_arn.value]
      }

      table {
        title = "MFA Devices"
        query = query.ram_user_mfa_devices
        args  = [self.input.user_arn.value]
      }

    }

  }

  container {

    title = "AliCloud RAM User Policy Analysis"

    flow {
      type  = "sankey"
      title = "Attached Policies"
      query = query.ram_user_manage_policies_sankey
      args  = [self.input.user_arn.value]

      category "ram_group" {
        color = "ok"
      }
    }

    table {
      title = "Groups"
      width = 6
      query = query.ram_groups_for_user
      args  = [self.input.user_arn.value]

      column "Name" {
        // cyclic dependency prevents use of url_path, hardcode for now
        href = "/alicloud_insights.dashboard.ram_group_detail?input.group_arn={{.'Group ARN' | @uri}}"

      }
    }

    table {
      title = "Policies"
      width = 6
      query = query.ram_all_policies_for_user
      args  = [self.input.user_arn.value]
    }

  }
}

query "ram_user_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id
      ) as tags
    from
      alicloud_ram_user
    order by
      title;
  EOQ
}

query "ram_user_mfa_for_user" {
  sql = <<-EOQ
    select
      case when mfa_enabled then 'Enabled' else 'Disabled' end as value,
      'MFA Status' as label,
      case when mfa_enabled then 'ok' else 'alert' end as type
    from
      alicloud_ram_user
    where
      arn = $1;
  EOQ

}

query "ram_user_direct_attached_policy_count_for_user" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Direct Attached Policies' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_user
    where
     arn = $1 and attached_policy = '[]';
  EOQ

}

# With queries

query "ram_groups_for_ram_user" {
  sql = <<-EOQ
    select
      g.arn as group_arn
    from
      alicloud_ram_user as u,
      alicloud_ram_group as g,
      jsonb_array_elements(u.groups) as ugrp
    where
      u.arn = $1
      and u.account_id = g.account_id
      and g.title = ugrp ->> 'GroupName';
  EOQ
}

query "ram_policies_for_ram_user" {
  sql = <<-EOQ
    select
      p.policy_name
    from
      alicloud_ram_user as u,
      alicloud_ram_policy as p,
      jsonb_array_elements(u.attached_policy) as policy
    where
      u.arn = $1
      and u.account_id = p.account_id
      and policy ->> 'PolicyName' = p.policy_name;
  EOQ
}

query "ram_user_overview" {
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
      arn = $1;
  EOQ

}

query "ram_user_access_keys" {
  sql = <<-EOQ
    select
      access_key_id  as "Access Key ID",
      a.status as "Status",
      a.create_date as "Create Date"
    from
      alicloud_ram_access_key as a left join alicloud_ram_user as u on u.name = a.user_name
    where
      u.arn  = $1;
  EOQ

}

query "ram_user_mfa_devices" {
  sql = <<-EOQ
    select
      mfa -> 'User' ->> 'UserId' as "User ID",
      mfa ->> 'SerialNumber' as "MFA Serial Number",
      mfa ->> 'ActivateDate' as "Activate Date"
    from
      alicloud_ram_user,
      jsonb_array_elements(virtual_mfa_devices) as mfa
    where
      arn  = $1;
  EOQ

}

query "ram_user_manage_policies_sankey" {
  sql = <<-EOQ

    with args as (
        select $1 as ram_user_arn
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
      arn in (select ram_user_arn from args)

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
      u.arn in (select ram_user_arn from args)

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
       and u.arn in (select ram_user_arn from args)

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
      and u.arn in (select ram_user_arn from args);
  EOQ

}

query "ram_groups_for_user" {
  sql = <<-EOQ
    select
      g ->> 'GroupName' as "Name",
      'acs:ram::' || account_id || ':group/' || (g ->> 'GroupName') as "Group ARN",
      g ->> 'JoinDate' as "Join Date"
    from
      alicloud_ram_user as u,
      jsonb_array_elements(groups) as g
    where
      u.arn = $1;
  EOQ

}

query "ram_all_policies_for_user" {
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
      and u.arn = $1

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
      and u.arn = $1;
  EOQ

}
