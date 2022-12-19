dashboard "ram_user_dashboard" {

  title         = "AliCloud RAM User Dashboard"
  documentation = file("./dashboards/ram/docs/ram_user_dashboard.md")

  tags = merge(local.ram_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.ram_user_count
      width = 2
    }

    # Assessments

    card {
      query = query.ram_user_no_mfa_count
      width = 2
      href  = dashboard.ram_user_mfa_report.url_path
    }

    card {
      query = query.ram_users_with_direct_policy_count
      width = 2
    }

  }

  container {
    title = "Assessments"

    chart {
      title = "MFA Status"
      query = query.ram_users_by_mfa_enabled
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Direct Attached Policies"
      query = query.ram_users_with_direct_attached_policy
      type  = "donut"
      width = 3

      series "count" {
        point "no attached policies" {
          color = "ok"
        }
        point "with attached policies" {
          color = "alert"
        }
      }
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Users by Account"
      query = query.ram_users_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Users by Age"
      query = query.ram_user_by_creation_month
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "ram_user_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Users' as label
    from
      alicloud_ram_user;
  EOQ
}

query "ram_user_no_mfa_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'MFA Not Enabled' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_user
    where
      not mfa_enabled;
  EOQ
}

query "ram_users_with_direct_policy_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'With Direct Attached Policies' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_user
    where
      attached_policy != '[]'
  EOQ
}

# Assessment Queries

query "ram_users_by_mfa_enabled" {
  sql = <<-EOQ
    with mfa_stat as (
      select
        case
          when mfa_enabled then 'enabled'
          else 'disabled'
        end as mfa_status
      from
        alicloud_ram_user
    )
    select
      mfa_status,
      count(*)
    from
      mfa_stat
    group by
      mfa_status;
  EOQ
}

query "ram_users_with_direct_attached_policy" {
  sql = <<-EOQ
    with direct_attached_policies as (
      select
        case
          when jsonb_array_length(attached_policy) > 0 then 'with attached policies'
          else 'no attached policies'
        end as has_attached
      from
        alicloud_ram_user
    )
    select
      has_attached,
      count(*)
    from
      direct_attached_policies
    group by
      has_attached;
  EOQ
}

# Analysis Queries

query "ram_users_by_account" {
  sql = <<-EOQ
    select
      a.title,
      count(*)
    from
      alicloud_ram_user as u,
      alicloud_account as a
    where
      u.account_id = a.account_id
    group by
      a.title
    order by
      count desc;
  EOQ
}

query "ram_user_by_creation_month" {
  sql = <<-EOQ
    with users as (
      select
        title,
        create_date,
        to_char(create_date,
          'YYYY-MM') as creation_month
      from
        alicloud_ram_user
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
                from users)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    users_by_month as (
      select
        creation_month,
        count(*)
      from
        users
      group by
        creation_month
    )
    select
      months.month,
      users_by_month.count
    from
      months
      left join users_by_month on months.month = users_by_month.creation_month
    order by
      months.month;
  EOQ
}
