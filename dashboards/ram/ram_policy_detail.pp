dashboard "ram_policy_detail" {
  title         = "AliCloud RAM Policy Detail"
  documentation = file("./dashboards/ram/docs/ram_policy_detail.md")
  tags = merge(local.ram_common_tags, {
    type = "Detail"
  })

  input "policy_name" {
    title = "Select a policy:"
    query = query.ram_policy_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.ram_policy_alicloud_managed
      args  = [self.input.policy_name.value]
    }

    card {
      width = 3
      query = query.ram_policy_attached
      args  = [self.input.policy_name.value]
    }
  }

  with "ram_groups_for_ram_policy" {
    query = query.ram_groups_for_ram_policy
    args  = [self.input.policy_name.value]
  }

  with "ram_policy_std_for_ram_policy" {
    query = query.ram_policy_std_for_ram_policy
    args  = [self.input.policy_name.value]
  }

  with "ram_roles_for_ram_policy" {
    query = query.ram_roles_for_ram_policy
    args  = [self.input.policy_name.value]
  }

  with "ram_users_for_ram_policy" {
    query = query.ram_users_for_ram_policy
    args  = [self.input.policy_name.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.ram_group
        args = {
          ram_group_arns = with.ram_groups_for_ram_policy.rows[*].group_arn
        }
      }

      node {
        base = node.ram_policy
        args = {
          ram_policy_names = [self.input.policy_name.value]
        }
      }

      node {
        base = node.ram_policy_statement
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      node {
        base = node.ram_policy_statement_action_notaction
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      node {
        base = node.ram_policy_statement_condition
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      node {
        base = node.ram_policy_statement_condition_key
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      node {
        base = node.ram_policy_statement_condition_key_value
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      node {
        base = node.ram_policy_statement_resource_notresource
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      node {
        base = node.ram_role
        args = {
          ram_role_arns = with.ram_roles_for_ram_policy.rows[*].role_arn
        }
      }

      node {
        base = node.ram_user
        args = {
          ram_user_arns = with.ram_users_for_ram_policy.rows[*].user_arn
        }
      }

      edge {
        base = edge.ram_group_to_ram_policy
        args = {
          ram_group_arns = with.ram_groups_for_ram_policy.rows[*].group_arn
        }
      }

      edge {
        base = edge.ram_policy_statement
        args = {
          ram_policy_names = [self.input.policy_name.value]
        }
      }

      edge {
        base = edge.ram_policy_statement_action
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_policy_statement_condition
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_policy_statement_condition_key
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_policy_statement_condition_key_value
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_policy_statement_notaction
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_policy_statement_notresource
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_policy_statement_resource
        args = {
          ram_policy_stds = with.ram_policy_std_for_ram_policy.rows[0].policy_document_std
        }
      }

      edge {
        base = edge.ram_role_to_ram_policy
        args = {
          ram_role_arns = with.ram_roles_for_ram_policy.rows[*].role_arn
        }
      }

      edge {
        base = edge.ram_user_to_ram_policy
        args = {
          ram_user_arns = with.ram_users_for_ram_policy.rows[*].user_arn
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
        query = query.ram_policy_overview
        args  = [self.input.policy_name.value]

      }
    }

    container {
      width = 8
      table {
        title = "Policy Statement"
        query = query.ram_policy_statement
        args  = [self.input.policy_name.value]
      }

    }

  }
}

# Input queries

query "ram_policy_input" {
  sql = <<-EOQ
    with policies as (
      select
        title as label,
        policy_name as value,
        json_build_object(
          'account_id', account_id
        ) as tags
      from
        alicloud_ram_policy
      where
        policy_type != 'System'
      union all select
        distinct on (policy_name)
        title as label,
        policy_name as value,
        json_build_object(
          'account_id', 'Alicloud Managed'
        ) as tags
      from
        alicloud_ram_policy
      where
        policy_type = 'System'
    )
    select
      *
    from
      policies
    order by
      label;
  EOQ
}

# With queries

query "ram_groups_for_ram_policy" {
  sql = <<-EOQ
    select
      arn as group_arn
    from
      alicloud_ram_group,
      jsonb_array_elements(attached_policy) as policy
    where
      policy ->> 'PolicyName' = $1;
  EOQ
}

query "ram_policy_std_for_ram_policy" {
  sql = <<-EOQ
    select
      policy_document_std
    from
      alicloud_ram_policy
    where
      title = $1
    limit 1;  -- alicloud managed policies will appear once for each connection in the aggregator, but we only need one...
  EOQ
}

query "ram_roles_for_ram_policy" {
  sql = <<-EOQ
    select
      arn as role_arn
    from
      alicloud_ram_role,
      jsonb_array_elements(attached_policy) as policy
    where
      policy ->> 'PolicyName' = $1;
  EOQ
}

query "ram_users_for_ram_policy" {
  sql = <<-EOQ
    select
      arn as user_arn
    from
      alicloud_ram_user,
      jsonb_array_elements(attached_policy) as policy
    where
      policy ->> 'PolicyName' = $1;
  EOQ
}

# Card queries

query "ram_policy_alicloud_managed" {
  sql = <<-EOQ
    select
      case when policy_type = 'System' then 'Alicloud' else 'Customer' end as value,
      'Managed By' as label
    from
      alicloud_ram_policy
    where
      policy_name = $1;
  EOQ
}

query "ram_policy_attached" {
  sql = <<-EOQ
    select
      case when attachment_count > 0 then 'Attached' else 'Detached' end as value,
      'Attachment Status' as label,
      case when attachment_count > 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_policy
    where
      policy_name = $1;
  EOQ
}

# Other detail page queries

query "ram_policy_overview" {
  sql = <<-EOQ
    select
      policy_name as "Name",
      description as "Description",
      create_date as "Create Date",
      attachment_count as "Attachment Count",
      default_version as "Default Version",
      update_date as "Update Date",
      case policy_type
        when 'System' then 'Alicloud Managed'
        else account_id
      end as "Account ID"
    from
      alicloud_ram_policy
    where
      title = $1
    limit 1
  EOQ
}

query "ram_policy_statement" {
  sql = <<-EOQ
    with policy as (
      select
        distinct on (policy_name)
        *
      from
        alicloud_ram_policy
      where
        policy_name =  $1
    )
    select
      coalesce(t.stmt ->> 'Sid', concat('[', i::text, ']')) as "Statement",
      t.stmt ->> 'Effect' as "Effect",
      action as "Action",
      notaction as "NotAction",
      resource as "Resource",
      notresource as "NotResource",
      t.stmt ->> 'Condition' as "Condition"
    from
      policy as p, --alicloud_ram_policy as p,
      jsonb_array_elements(p.policy_document_std -> 'Statement') with ordinality as t(stmt,i)
      left join jsonb_array_elements_text(t.stmt -> 'Action') as action on true
      left join jsonb_array_elements_text(t.stmt -> 'NotAction') as notaction on true
      left join jsonb_array_elements_text(t.stmt -> 'Resource') as resource on true
      left join jsonb_array_elements_text(t.stmt -> 'NotResource') as notresource on true
  EOQ
}



