dashboard "alicloud_ram_role_dashboard" {

  title         = "Alicloud RAM Role Dashboard"
  documentation = file("./dashboards/ram/docs/ram_role_dashboard.md")

  tags = merge(local.ram_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis

    card {
      query = query.alicloud_ram_role_count
      width = 2
    }

    card {
      query = query.alicloud_ram_roles_without_policy_count
      width = 2
    }

    card {
      query = query.alicloud_ram_role_with_admin_access_count
      width = 2
    }

    card {
      query = query.alicloud_ram_role_allows_cross_account_access_count
      width = 2
    }

  }

  container {
    title = "Assessments"

    chart {
      title = "Allows Administrator Actions"
      query = query.alicloud_ram_roles_allow_admin_action
      type  = "donut"
      width = 3

      series "count" {
        point "no admin access" {
          color = "ok"
        }
        point "with admin access" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Allows Cross-Account Access"
      query = query.alicloud_ram_roles_allow_cross_account_access
      type  = "donut"
      width = 3

      series "count" {
        point "no cross-account access" {
          color = "ok"
        }
        point "allows cross-account access" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Roles by Account"
      query = query.alicloud_ram_roles_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Roles by Age"
      query = query.alicloud_ram_roles_by_creation_month
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "alicloud_ram_role_count" {
  sql = <<-EOQ
    select count(*) as "Roles" from alicloud_ram_role;
  EOQ
}

query "alicloud_ram_roles_without_policy_count" {
  sql = <<-EOQ
    select
      count(*) as value,
       'Without Policies' as label,
      case when count(*) > 0 then 'alert' else 'ok' end as type
    from
      alicloud_ram_role
    where
      attached_policy = '[]';
  EOQ
}

query "alicloud_ram_role_with_admin_access_count" {
  sql = <<-EOQ
    select
      count(distinct name) as value,
      'With Administrator Access' as label,
      case when count(distinct name) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_role,
      jsonb_array_elements(attached_policy) as policies
    where
      policies ->> 'PolicyName' = 'AdministratorAccess';
  EOQ
}

query "alicloud_ram_role_allows_cross_account_access_count" {
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
      count(name) as value,
      'With Cross-Account Access' as label,
      case when count(name) > 0 then 'alert' else 'ok' end as type
    from
      roles_with_cross_account_access;
  EOQ
}

# Assessment Queries

query "alicloud_ram_roles_allow_admin_action" {
  sql = <<-EOQ
    with admin_role_access as (
      select
        distinct name
      from
        alicloud_ram_role,
        jsonb_array_elements(attached_policy) as policies
      where
        policies ->> 'PolicyName' = 'AdministratorAccess'
    )
    select
      case
      when a.name is null then 'no admin access' else 'with admin access' end as status,
      count(*)
    from
      alicloud_ram_role as r
      left join admin_role_access as a on r.name = a.name
    group by
      status;
  EOQ
}

query "alicloud_ram_roles_allow_cross_account_access" {
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
      case
      when a.name is null then 'no cross-account access' else 'allows cross-account access' end as status,
      count(*)
    from
      alicloud_ram_role as r
      left join roles_with_cross_account_access as a on r.name = a.name
    group by
      status;
  EOQ
}

# Analysis Queries

query "alicloud_ram_roles_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(i.*) as "total"
    from
      alicloud_ram_role as i,
      alicloud_account as a
    where
      a.account_id = i.account_id
    group by
      account
    order by count(i.*) desc;
  EOQ
}

query "alicloud_ram_roles_by_creation_month" {
  sql = <<-EOQ
    with roles as (
      select
        title,
        create_date,
        to_char(create_date,
          'YYYY-MM') as creation_month
      from
        alicloud_ram_role
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
                from roles)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    roles_by_month as (
      select
        creation_month,
        count(*)
      from
        roles
      group by
        creation_month
    )
    select
      months.month,
      roles_by_month.count
    from
      months
      left join roles_by_month on months.month = roles_by_month.creation_month
    order by
      months.month;
  EOQ
}
