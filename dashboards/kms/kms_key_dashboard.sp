dashboard "alicloud_kms_key_dashboard" {

  title         = "Alibaba Cloud KMS Key Dashboard"
  documentation = file("./dashboards/kms/docs/kms_key_dashboard.md")

  tags = merge(local.kms_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      sql   = query.alicloud_kms_key_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_kms_customer_managed_key_count.sql
      width = 2
    }

    # Assessments
    card {
      sql   = query.alicloud_kms_key_disabled_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_kms_deletion_protection_disabled_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_kms_cmk_rotation_disabled_count.sql
      width = 2
      href  = dashboard.alicloud_kms_key_lifecycle_report.url_path
    }
  }

  container {

    title = "Assessments"
    width = 6

    chart {
      title = "Enabled/Disabled Status"
      sql   = query.alicloud_kms_key_disabled_status.sql
      type  = "donut"
      width = 4

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
      title = "CMK Rotation Status"
      sql   = query.alicloud_kms_key_rotation_status.sql
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Keys by Account"
      sql   = query.alicloud_kms_key_by_account.sql
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by Region"
      sql   = query.alicloud_kms_key_by_region.sql
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by State"
      sql   = query.alicloud_kms_key_by_state.sql
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by Age"
      sql   = query.alicloud_kms_key_by_creation_month.sql
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "alicloud_kms_key_count" {
  sql = <<-EOQ
    select count(*) as "Keys" from alicloud_kms_key;
  EOQ
}

query "alicloud_kms_customer_managed_key_count" {
  sql = <<-EOQ
    select
      count(*)as "Customer Managed Keys"
    from
      alicloud_kms_key
    --where
     -- key_manager = 'CUSTOMER';
  EOQ
}

query "alicloud_kms_key_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      key_state = 'Disabled';
  EOQ
}

query "alicloud_kms_cmk_rotation_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'CMK Rotation Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      automatic_rotation = 'Disabled';
      -- and key_manager = 'CUSTOMER';
  EOQ
}

query "alicloud_kms_deletion_protection_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'CMK Deletion Protection Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      deletion_protection = 'Disabled';
      -- and key_manager = 'CUSTOMER';
  EOQ
}

# Assessment Queries

query "alicloud_kms_key_disabled_status" {
  sql = <<-EOQ
    select
      disabled_status,
      count(*)
    from (
      select
        key_state as disabled_status
      from
        alicloud_kms_key) as t
    group by
      disabled_status
    order by
      disabled_status desc;
  EOQ
}

query "alicloud_kms_key_rotation_status" {
  sql = <<-EOQ
    select
      rotation_status,
      count(*)
    from (
      select
        automatic_rotation as rotation_status
      from
        alicloud_kms_key
      --where
        --key_manager = 'CUSTOMER'
        ) as t
    group by
      rotation_status
    order by
      rotation_status desc;
  EOQ
}

# Analysis Queries

query "alicloud_kms_key_by_account" {
  sql = <<-EOQ
    select
      a.title as "Account",
      count(i.*) as "Keys"
    from
      alicloud_kms_key as i,
      alicloud_account as a
    where
      a.account_id = i.account_id
    group by
      a.title
    order by
      a.title;
  EOQ
}

query "alicloud_kms_key_by_region" {
  sql = <<-EOQ
    select
      region,
      count(i.*) as "Keys"
    from
      alicloud_kms_key as i
    group by
      region;
  EOQ
}

query "alicloud_kms_key_by_state" {
  sql = <<-EOQ
    select
      key_state,
      count(key_state)
    from
      alicloud_kms_key
    group by
      key_state;
  EOQ
}

query "alicloud_kms_key_by_creation_month" {
  sql = <<-EOQ
    with keys as (
      select
        title,
        creation_date,
        to_char(creation_date,
          'YYYY-MM') as creation_month
      from
        alicloud_kms_key
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
            (
              select
                min(creation_date)
                from keys)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    keys_by_month as (
      select
        creation_month,
        count(*)
      from
        keys
      group by
        creation_month
    )
    select
      months.month,
      keys_by_month.count
    from
      months
      left join keys_by_month on months.month = keys_by_month.creation_month
    order by
      months.month;
  EOQ
}