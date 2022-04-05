dashboard "alicloud_ram_group_dashboard" {

  title = "Alicloud RAM Group Dashboard"
  documentation = file("./dashboards/ram/docs/ram_group_dashboard.md")


  tags = merge(local.ram_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query   = query.alicloud_ram_group_count
      width = 2
    }

    # Assessments
    card {
      query   = query.alicloud_ram_groups_without_users_count
      width = 2
    }

    card {
      query   = query.alicloud_ram_groups_with_custom_attached_policy_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Groups Without Users"
      query   = query.alicloud_ram_groups_without_users
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
      title = "Custom Policies"
      query   = query.alicloud_ram_groups_with_custom_policy
      type  = "donut"
      width = 3

      series "count" {
        point "no custom policies" {
          color = "ok"
        }
        point "with custom policies" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Groups by Account"
      query   = query.alicloud_ram_groups_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Groups by Age"
      query   = query.alicloud_ram_groups_by_creation_month
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "alicloud_ram_group_count" {
  sql = <<-EOQ
    select count(*) as "Groups" from alicloud_ram_group;
  EOQ
}

query "alicloud_ram_groups_without_users_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Without Users' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_group
    where
      users is null;
  EOQ
}

query "alicloud_ram_groups_with_custom_attached_policy_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'With Custom Policies' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_group,
      jsonb_array_elements(attached_policy) as policies
    where
      policies ->> 'PolicyType' = 'Custom';
  EOQ
}

# Assessment Queries

query "alicloud_ram_groups_without_users" {
  sql = <<-EOQ
    with groups_without_users as (
      select
        title,
        case
          when users is null then 'no users'
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

query "alicloud_ram_groups_with_attached_policy" {
  sql = <<-EOQ
    with group_attached_policy as (
      select
        title,
        case
          when jsonb_array_length(attached_policy) > 0 then 'with attached policies'
          else 'no attached policies'
        end as has_attached_policy
      from
        alicloud_ram_group
      )
      select
        has_attached_policy,
        count(*)
      from
        group_attached_policy
      group by
        has_attached_policy;
  EOQ
}

query "alicloud_ram_groups_with_custom_policy" {
  sql = <<-EOQ
    with group_custom_policy as (
    select
      title,
      case
        when policies ->> 'PolicyType' = 'Custom' then 'with custom policies'
        else 'no custom policies'
      end as has_custom_policy
    from
      alicloud_ram_group,
      jsonb_array_elements(attached_policy) as policies
    )
    select
      has_custom_policy,
      count(*)
    from
      group_custom_policy
    group by
      has_custom_policy;
  EOQ
}

# Analysis Queries

query "alicloud_ram_groups_by_account" {
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

query "alicloud_ram_groups_by_creation_month" {
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
