dashboard "alicloud_ram_role_detail" {

  title         = "Alicloud RAM Role Detail"
  documentation = file("./dashboards/ram/docs/ram_role_detail.md")

  tags = merge(local.ram_common_tags, {
    type = "Detail"
  })

  input "role_arn" {
    title = "Select a role:"
    query = query.alicloud_ram_role_input
    width = 2
  }

  container {

    card {
      width = 2
      query = query.alicloud_ram_role_policy_count_for_role
      args = {
        arn = self.input.role_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ram_role_with_admin_access
      args = {
        arn = self.input.role_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ram_role_with_cross_account_access
      args = {
        arn = self.input.role_arn.value
      }
    }

  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.alicloud_ram_role_overview
        args = {
          arn = self.input.role_arn.value
        }
      }

    }

    container {

      title = "Alicloud RAM Role Policy Analysis"

      hierarchy {
        type  = "tree"
        width = 6
        title = "Attached Policies"
        query = query.alicloud_ram_user_manage_policies_hierarchy
        args = {
          arn = self.input.role_arn.value
        }

        category "managed_policy" {
          color = "ok"
        }

      }


      table {
        title = "Policies"
        width = 6
        query = query.alicloud_ram_policies_for_role
        args = {
          arn = self.input.role_arn.value
        }
      }

    }
  }

}

query "alicloud_ram_role_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id
      ) as tags
    from
      alicloud_ram_role
    order by
      title;
  EOQ
}

query "alicloud_ram_role_policy_count_for_role" {
  sql = <<-EOQ
    select
      case when attached_policy = '[]' then 0 else jsonb_array_length(attached_policy) end as value,
      'Policies' as label
    from
      alicloud_ram_role
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ram_role_with_admin_access" {
  sql = <<-EOQ
    with admin_roles as (
      select
        distinct name
    from
      alicloud_ram_role,
      jsonb_array_elements(attached_policy) as policies
    where
      policies ->> 'PolicyName' = 'AdministratorAccess'
    )
    select
       case when a.name is not null then 'Enabled' else 'Disabled' end as value,
      'Admin Access' as label,
      case when a.name is not null then 'alert' else 'ok' end as type
    from
      alicloud_ram_role as r
      left join admin_roles as a on r.name = a.name
    where
      r.arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ram_role_with_cross_account_access" {
  sql = <<-EOQ
    with roles_with_cross_account_access as (
      select
        distinct name as name
      from
        alicloud_ram_role,
        jsonb_array_elements(assume_role_policy_document -> 'Statement') as stmt,
        jsonb_array_elements_text(stmt -> 'Principal' -> 'RAM') as principal
      where
        split_part(principal, ':',4) <> account_id
    )
    select
       case when a.name is not null then 'Enabled' else 'Disabled' end as value,
      'Cross-Account Access' as label,
      case when a.name is not null then 'alert' else 'ok' end as type
    from
      alicloud_ram_role as r
      left join roles_with_cross_account_access as a on r.name = a.name
    where
      r.arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ram_role_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      create_date as "Create Date",
      update_date as "Last Update Date",
      max_session_duration as "Max Session Duration",
      description as "Description",
      role_id as "Role ID",
      arn as "ARN",
      account_id as "Account ID"
    from
      alicloud_ram_role
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ram_policies_for_role" {
  sql = <<-EOQ
    select
      policies ->> 'PolicyName' as "Name",
      policies ->> 'PolicyType' as "Type",
      policies ->> 'DefaultVersion' as "Default Version",
      policies ->> 'AttachDate' as "Attachment Date"
    from
      alicloud_ram_role,
      jsonb_array_elements(attached_policy) as policies
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ram_user_manage_policies_hierarchy" {
  sql = <<-EOQ
    select
      r.name as id,
      r.name as title,
      'role' as category,
      null as from_id
    from
      alicloud_ram_role as r
    where
      r.arn = $1

    -- Policies (attached to groups)
    union select
      policy ->> 'PolicyName' as id,
      policy ->> 'PolicyName' as title,
      'managed_policy' as category,
      r.name as from_id
    from
      alicloud_ram_role as r,
      jsonb_array_elements(r.attached_policy) as policy
    where
      r.arn = $1;
  EOQ

  param "arn" {}
}
