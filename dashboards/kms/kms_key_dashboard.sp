dashboard "kms_key_dashboard" {

  title         = "AliCloud KMS Key Dashboard"
  documentation = file("./dashboards/kms/docs/kms_key_dashboard.md")

  tags = merge(local.kms_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.kms_key_count
      width = 2
    }

    card {
      query = query.hsm_based_keys
      width = 2
    }

    # Assessments
    card {
      query = query.kms_key_disabled_count
      width = 2
    }

    card {
      query = query.kms_cmk_rotation_disabled_count
      width = 2
      href  = dashboard.kms_key_lifecycle_report.url_path
    }

    card {
      query = query.kms_deletion_protection_disabled_count
      width = 2
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Enabled/Disabled Status"
      query = query.kms_key_disabled_status
      type  = "donut"
      width = 3

      series "Keys" {
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
      query = query.kms_key_rotation_status
      type  = "donut"
      width = 3

      series "Keys" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "CMK Deletion Protection Status"
      query = query.kms_key_rotation_status
      type  = "donut"
      width = 3

      series "Keys" {
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
      query = query.kms_key_by_account
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by Region"
      query = query.kms_key_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by State"
      query = query.kms_key_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by Age"
      query = query.kms_key_by_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Keys by Protection Level"
      query = query.kms_key_by_protection_level
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

# Analysis Card Queries

query "kms_key_count" {
  sql = <<-EOQ
    select count(*) as "Keys" from alicloud_kms_key;
  EOQ
}

query "hsm_based_keys" {
  sql = <<-EOQ
    select
      count(*) as "HSM Based Keys"
    from
      alicloud_kms_key
    where
      protection_level = 'HSM';
  EOQ
}

# Assessments Card Queries

query "kms_key_disabled_count" {
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

query "kms_cmk_rotation_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'CMK Rotation Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      automatic_rotation = 'Disabled';
  EOQ
}

query "kms_deletion_protection_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'CMK Deletion Protection Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      deletion_protection = 'Disabled';
  EOQ
}

# Assessment Queries

query "kms_key_disabled_status" {
  sql = <<-EOQ
    select
      lower(disabled_status),
      count(*) as "Keys"
    from (
      select
        key_state as disabled_status
      from
        alicloud_kms_key
      where
        lower(key_state) != 'pendingdeletion') as t
    group by
      disabled_status
    order by
      disabled_status desc;
  EOQ
}

query "kms_key_rotation_status" {
  sql = <<-EOQ
    select
      lower(rotation_status),
      count(*) as "Keys"
    from (
      select
        automatic_rotation as rotation_status
      from
        alicloud_kms_key) as t
    group by
      rotation_status
    order by
      rotation_status desc;
  EOQ
}

query "kms_key_deletion_protection_status" {
  sql = <<-EOQ
    select
      lower(deletion_protection),
      count(*) as "Keys"
    from (
      select
        deletion_protection as deletion_protection
      from
        alicloud_kms_key) as t
    group by
      deletion_protection
    order by
      deletion_protection desc;
  EOQ
}

# Analysis Queries

query "kms_key_by_account" {
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

query "kms_key_by_region" {
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

query "kms_key_by_state" {
  sql = <<-EOQ
    select
      key_state,
      count(key_state) as "Keys"
    from
      alicloud_kms_key
    group by
      key_state;
  EOQ
}

query "kms_key_by_protection_level" {
  sql = <<-EOQ
    select
      protection_level,
      count(key_state) as "Keys"
    from
      alicloud_kms_key
    group by
      protection_level;
  EOQ
}

query "kms_key_by_creation_month" {
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
      keys_by_month.count as "Keys"
    from
      months
      left join keys_by_month on months.month = keys_by_month.creation_month
    order by
      months.month;
  EOQ
}
