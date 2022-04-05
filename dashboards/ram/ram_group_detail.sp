dashboard "alicloud_ram_group_detail" {

  title         = "Alicloud RAM Group Detail"
  documentation = file("./dashboards/ram/docs/ram_group_detail.md")


  tags = merge(local.ram_common_tags, {
    type = "Detail"
  })

  input "group_title" {
    title = "Select a group:"
    query   = query.alicloud_ram_group_input
    width = 2
  }

  container {

    card {
      width = 2
      query = query.alicloud_ram_group_custom_policy_count_for_group
      args = {
        title = self.input.group_title.value
      }
    }

  }

  container {

    container {

      title = "Overview"

      table {
        type  = "line"
        width = 6
        query = query.alicloud_ram_group_overview
        args = {
          title = self.input.group_title.value
        }

      }

    }

  }

  container {

    title = "Alicloud RAM Group Analysis"

    table {
      title = "Users"
      width = 6
      # column "User Name" {
      #   href = "${dashboard.ram_iam_user_detail.url_path}?input.user_arn={{.'User ARN' | @uri}}"
      # }

      query = query.alicloud_ram_users_for_group
      args = {
        title = self.input.group_title.value
      }

    }

    table {
      title = "Policies"
      width = 6
      query = query.alicloud_ram_all_policies_for_group
      args = {
        title = self.input.group_title.value
      }
    }

  }

}

query "alicloud_ram_group_input" {
  sql = <<-EOQ
    select
      title as label,
      title as value,
      json_build_object(
        'account_id', account_id
      ) as tags
    from
      alicloud_ram_group
    order by
      title;
  EOQ
}

query "alicloud_ram_group_custom_policy_count_for_group" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Custom Policies' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_group,
      jsonb_array_elements(attached_policy) as policies
    where
      policies ->> 'PolicyType' = 'Custom' and title = $1
  EOQ

  param "title" {}
}

query "alicloud_ram_group_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      title as "Title",
      create_date as "Create Date",
      account_id as "Account ID"
    from
      alicloud_ram_group
    where
      title = $1
  EOQ

  param "title" {}
}

query "alicloud_ram_users_for_group" {
  sql = <<-EOQ
    select
      u ->> 'UserName' as "User Name",
      u ->> 'DisplayName' as "Display Name",
      u ->> 'JoinDate' as "Join Date"
    from
      alicloud_ram_group as g,
      jsonb_array_elements(users) as u
    where
      title = $1
  EOQ

  param "title" {}
}

query "alicloud_ram_all_policies_for_group" {
  sql = <<-EOQ
    select
      policies ->> 'PolicyName' as "Name",
      policies ->> 'PolicyType' as "Type",
      policies ->> 'DefaultVersion' as "Default Version",
      policies ->> 'AttachDate' as "Attachment Date"
    from
      alicloud_ram_group,
      jsonb_array_elements(attached_policy) as policies
    where
      title = $1
  EOQ

  param "title" {}
}
