dashboard "oss_bucket_dashboard" {

  title         = "AliCloud OSS Bucket Dashboard"
  documentation = file("./dashboards/oss/docs/oss_bucket_dashboard.md")

  tags = merge(local.oss_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.oss_bucket_count
      width = 2
    }

    # Assessments
    card {
      query = query.oss_bucket_public_access_not_blocked_count
      width = 2
      href  = dashboard.oss_bucket_public_access_report.url_path
    }

    card {
      query = query.oss_bucket_unencrypted_count
      width = 2
      href  = dashboard.oss_bucket_encryption_report.url_path
    }

    card {
      query = query.oss_bucket_ssl_not_enforced_count
      width = 2
    }

    card {
      query = query.oss_bucket_logging_disabled_count
      width = 2
      href  = dashboard.oss_bucket_logging_report.url_path
    }

    card {
      query = query.oss_bucket_versioning_disabled_count
      width = 2
      href  = dashboard.oss_bucket_lifecycle_report.url_path
    }

  }

  container {
    title = "Assessments"
    # width = 12

    chart {
      title = "Public/Private"
      query = query.oss_bucket_by_public_access_blocked_status
      type  = "donut"
      width = 4

      series "count" {
        point "private" {
          color = "ok"
        }
        point "public" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Encryption Status"
      query = query.oss_bucket_by_default_encryption_status
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
      title = "HTTPS Enforcement Status"
      query = query.oss_bucket_by_ssl_enforced_status
      type  = "donut"
      width = 4

      series "count" {
        point "enforced" {
          color = "ok"
        }
        point "not enforced" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Logging Status"
      query = query.oss_bucket_by_logging_status
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
      title = "Versioning Status"
      query = query.oss_bucket_by_versioning_status
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
      title = "Buckets by Account"
      query = query.oss_bucket_by_account
      type  = "column"
      width = 3
    }

    chart {
      title = "Buckets by Region"
      query = query.oss_bucket_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Buckets by Age"
      query = query.oss_bucket_by_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Buckets by Storage"
      query = query.oss_bucket_by_storage_class
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "oss_bucket_count" {
  sql = <<-EOQ
    select count(*) as "Buckets" from alicloud_oss_bucket;
  EOQ
}

query "oss_bucket_public_access_not_blocked_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_oss_bucket
    where
      acl <> 'private';
  EOQ
}

query "oss_bucket_unencrypted_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_oss_bucket
    where
      server_side_encryption ->> 'SSEAlgorithm' = '';
  EOQ
}

query "oss_bucket_logging_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Logging Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_oss_bucket
    where
      logging ->> 'TargetBucket' = '';
  EOQ
}

query "oss_bucket_versioning_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Versioning Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_oss_bucket
    where
      versioning <> 'Enabled';
  EOQ
}

query "oss_bucket_ssl_not_enforced_count" {
  sql = <<-EOQ
    with ssl_ok as (
      select
        distinct name
      from
        alicloud_oss_bucket,
        jsonb_array_elements(policy -> 'Statement') as s,
        jsonb_array_elements_text(s -> 'Principal') as p,
        jsonb_array_elements_text(s -> 'Resource') as r,
        jsonb_array_elements_text(
          s -> 'Condition' -> 'Bool' -> 'acs:SecureTransport'
        ) as ssl
      where
        p = '*'
        and s ->> 'Effect' = 'Deny'
        and ssl :: bool = false
    )
    select
      count(*) as value,
      'HTTPS Unenforced' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_oss_bucket b
    where
      b.name not in (
        select name from ssl_ok
      );
  EOQ
}

# Assessment Queries

query "oss_bucket_by_public_access_blocked_status" {
  sql = <<-EOQ
    with public_block_status as (
      select
        case
          when
            acl = 'private'
          then 'private' else 'public'
        end as block_status
      from
        alicloud_oss_bucket
    )
    select
      block_status,
      count(*)
    from
      public_block_status
    group by
      block_status;
  EOQ
}

query "oss_bucket_by_default_encryption_status" {
  sql = <<-EOQ
    with default_encryption as (
      select
        case when server_side_encryption ->> 'SSEAlgorithm' = '' then 'disabled' else 'enabled'
        end as status
      from
        alicloud_oss_bucket
    )
    select
      status,
      count(*)
    from
      default_encryption
    group by
      status;
  EOQ
}

query "oss_bucket_by_logging_status" {
  sql = <<-EOQ
    with logging_status as (
      select
        case when logging ->> 'TargetBucket' = '' then 'disabled' else 'enabled'
        end as status
      from
        alicloud_oss_bucket
    )
    select
      status,
      count(*)
    from
      logging_status
    group by
      status;
  EOQ
}

query "oss_bucket_by_versioning_status" {
  sql = <<-EOQ
    with versioning_status as (
      select
        case
          when versioning = 'Enabled' then 'enabled' else 'disabled'
        end as status
      from
        alicloud_oss_bucket
    )
    select
      status,
      count(*)
    from
      versioning_status
    group by
      status;
  EOQ
}

query "oss_bucket_by_ssl_enforced_status" {
  sql = <<-EOQ
    with ssl_ok as (
      select
        distinct name
      from
        alicloud_oss_bucket,
        jsonb_array_elements(policy -> 'Statement') as s,
        jsonb_array_elements_text(s -> 'Principal') as p,
        jsonb_array_elements_text(s -> 'Resource') as r,
        jsonb_array_elements_text(
          s -> 'Condition' -> 'Bool' -> 'acs:SecureTransport'
        ) as ssl
      where
        p = '*'
        and s ->> 'Effect' = 'Deny'
        and ssl :: bool = false
    ),
    ssl_enforced_status as (
      select
        case
          when s.name is not null then 'enforced' else 'not enforced'
        end as status
      from
        alicloud_oss_bucket b
        left join ssl_ok s on s.name = b.name
    )
    select
      status,
      count(*)
    from
      ssl_enforced_status
    group by
      status;
  EOQ
}

# Analysis Queries

query "oss_bucket_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(i.*) as "total"
    from
      alicloud_oss_bucket as i,
      alicloud_account as a
    where
      a.account_id = i.account_id
    group by
      account
    order by count(i.*) desc;
  EOQ
}

query "oss_bucket_by_region" {
  sql = <<-EOQ
    select
      region,
      count(i.*) as "total"
    from
      alicloud_oss_bucket as i
    group by
      region;
  EOQ
}

query "oss_bucket_by_creation_month" {
  sql = <<-EOQ
    with buckets as (
      select
        title,
        creation_date,
        to_char(creation_date,
          'YYYY-MM') as creation_month
      from
        alicloud_oss_bucket
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
                from buckets)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    buckets_by_month as (
      select
        creation_month,
        count(*)
      from
        buckets
      group by
        creation_month
    )
    select
      months.month,
      buckets_by_month.count as "total"
    from
      months
      left join buckets_by_month on months.month = buckets_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "oss_bucket_by_storage_class" {
  sql = <<-EOQ
    select
      storage_class,
      count(i.*) as "total"
    from
      alicloud_oss_bucket as i
    group by
      storage_class;
  EOQ
}
