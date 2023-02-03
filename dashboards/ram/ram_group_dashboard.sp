dashboard "ram_group_dashboard" {

  title         = "AliCloud RAM Group Dashboard"
  documentation = file("./dashboards/ram/docs/ram_group_dashboard.md")


  tags = merge(local.ram_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.ram_group_count
      width = 3
    }

    # Assessments

    card {
      query = query.ram_groups_without_users_count
      width = 3
    }

    card {
      query = query.ram_groups_with_no_attached_policy_count
      width = 3
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Groups Without Users"
      query = query.ram_groups_without_users
      type  = "donut"
      width = 3

      series "count" {
        point "with users" {
          color = "ok"
        }
        point "no users" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Groups Without Policies"
      query = query.ram_groups_without_policies
      type  = "donut"
      width = 3

      series "count" {
        point "with policies" {
          color = "ok"
        }
        point "no policies" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Groups by Account"
      query = query.ram_groups_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Groups by Age"
      query = query.ram_groups_by_creation_month
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "ram_group_count" {
  sql = <<-EOQ
    select count(*) as "Groups" from alicloud_ram_group;
  EOQ
}

query "ram_groups_without_users_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Without Users' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_group
    where
      users = '[]';
  EOQ
}

query "ram_groups_with_no_attached_policy_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'With No Policies' as label,
      case when jsonb_array_length(attached_policy) = 0 then 'alert' else 'ok' end as type
    from
      alicloud_ram_group
    group by attached_policy
  EOQ
}

# Assessment Queries

query "ram_groups_without_users" {
  sql = <<-EOQ
    with groups_without_users as (
      select
        title,
        case
          when users = '[]' then 'no users'
          else 'with users'
        end as has_users
      from
        alicloud_ram_group
      )
      select
        has_users,
        count(*)
      from
        groups_without_users
      group by
        has_users;
  EOQ
}

query "ram_groups_without_policies" {
  sql = <<-EOQ
    with groups_without_policies as (
      select
        title,
        case
          when jsonb_array_length(attached_policy) = 0 then 'no policies'
          else 'with policies'
        end as has_policies
      from
        alicloud_ram_group
      )
      select
        has_policies,
        count(*)
      from
        groups_without_policies
      group by
        has_policies;
  EOQ
}




# Analysis Queries

query "ram_groups_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(g.*) as "total"
    from
      alicloud_ram_group as g,
      alicloud_account as a
    where
      a.account_id = g.account_id
    group by
      account
    order by count(g.*) desc;
  EOQ
}

query "ram_groups_by_creation_month" {
  sql = <<-EOQ
    with groups as (
      select
        title,
        create_date,
        to_char(create_date,
          'YYYY-MM') as creation_month
      from
        alicloud_ram_group
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
          (
            select
              min(create_date)
              from groups)),
          date_trunc('month',
            current_date),
          interval '1 month') as d
    ),
    groups_by_month as (
      select
        creation_month,
        count(*)
      from
        groups
      group by
        creation_month
    )
    select
      months.month,
      groups_by_month.count
    from
      months
      left join groups_by_month on months.month = groups_by_month.creation_month
    order by
      months.month;
  EOQ
}
