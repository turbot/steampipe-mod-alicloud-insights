dashboard "alicloud_ecs_snapshot_dashboard" {

  title         = "Alicloud ECS Snapshot Dashboard"
  documentation = file("./dashboards/ecs/docs/ecs_snapshot_dashboard.md")

  tags = merge(local.ecs_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.alicloud_ecs_snapshot_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_snapshot_storage_total
      width = 2
    }

    card {
      query = query.alicloud_ecs_unused_snapshot_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_unencrypted_snapshot_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Usage Status"
      query   = query.alicloud_ecs_snapshot_by_usage
      type  = "donut"
      width = 4

      series "Snapshots" {
        point "in-use" {
          color = "ok"
        }
        point "unused" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Encryption Status"
      query   = query.alicloud_ecs_snapshot_by_encryption_status
      type  = "donut"
      width = 4

      series "Snapshots" {
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
      title = "Snapshots by Account"
      query = query.alicloud_ecs_snapshot_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Snapshots by Region"
      query = query.alicloud_ecs_snapshot_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "Snapshots by Age"
      query = query.alicloud_ecs_snapshot_by_creation_month
      type  = "column"
      width = 4
    }

  }

  container {

    chart {
      title = "Storage by Account (GB)"
      query = query.alicloud_ecs_snapshot_storage_by_account
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Region (GB)"
      query = query.alicloud_ecs_snapshot_storage_by_region
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Age (GB)"
      query = query.alicloud_ecs_snapshot_storage_by_age
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }


  }

}

# Card Queries

query "alicloud_ecs_snapshot_count" {
  sql = <<-EOQ
    select count(*) as "Snapshots" from alicloud_ecs_snapshot;
  EOQ
}

query "alicloud_ecs_snapshot_storage_total" {
  sql = <<-EOQ
    select
        sum(CAST (source_disk_size AS INTEGER)) as "Total Storage (GB)"
    from
        alicloud_ecs_snapshot;
  EOQ
}

query "alicloud_ecs_unused_snapshot_count" {
  sql = <<-EOQ
    select
        count(*) as value,
        'Unused' as label,
        case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        alicloud_ecs_snapshot
    where
        usage = 'none';
  EOQ
}

query "alicloud_ecs_unencrypted_snapshot_count" {
  sql = <<-EOQ
    select
        count(*) as value,
        'Unencrypted' as label,
        case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        alicloud_ecs_snapshot
    where
        not encrypted;
  EOQ
}

# Assessment Queries

query "alicloud_ecs_snapshot_by_usage" {
  sql = <<-EOQ
    select
      snapshot_usage,
      count(*) as "Snapshots"
    from (
      select usage,
        case when usage = 'none' then
          'unused'
        else
          'in-use'
        end snapshot_usage
      from
        alicloud_ecs_snapshot) as t
    group by
      snapshot_usage
    order by
      snapshot_usage;
  EOQ
}

query "alicloud_ecs_snapshot_by_encryption_status" {
  sql = <<-EOQ
    select
      encryption_status,
      count(*) as "Snapshots"
    from (
      select encrypted,
        case when encrypted then
          'enabled'
        else
          'disabled'
        end encryption_status
      from
        alicloud_ecs_snapshot) as t
    group by
      encryption_status
    order by
      encryption_status;
  EOQ
}

# Analysis Queries

query "alicloud_ecs_snapshot_by_account" {
  sql = <<-EOQ
    select
      a.title as "Account",
      count(s.*) as "Snapshots"
    from
      alicloud_ecs_snapshot as s,
      alicloud_account as a
    where
      a.account_id = s.account_id
    group by
      a.title
    order by
      a.title;
  EOQ
}

query "alicloud_ecs_snapshot_by_region" {
  sql = <<-EOQ
    select 
      region as "Region",
      count(*) as "Snapshots" 
    from 
      alicloud_ecs_snapshot 
    group by 
      region
    order by
      region
  EOQ
}

query "alicloud_ecs_snapshot_by_creation_month" {
  sql = <<-EOQ
    with snapshots as (
      select
        title,
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        alicloud_ecs_snapshot
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
            (
              select
                min(creation_time)
                from snapshots)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    snapshots_by_month as (
      select
        creation_month,
        count(*)
      from
        snapshots
      group by
        creation_month
    )
    select
      months.month,
      snapshots_by_month.count as "Snapshots"
    from
      months
      left join snapshots_by_month on months.month = snapshots_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "alicloud_ecs_snapshot_storage_by_account" {
  sql = <<-EOQ
    select
      a.title as "Account",
      sum(CAST (s.source_disk_size AS INTEGER)) as "GB"
    from
      alicloud_ecs_snapshot as s,
      alicloud_account as a
    where
      a.account_id = s.account_id
    group by
      a.title
    order by
      a.title;
  EOQ
}

query "alicloud_ecs_snapshot_storage_by_region" {
  sql = <<-EOQ
    select
      region as "Region",
      sum(CAST (source_disk_size AS INTEGER)) as "GB"
    from
      alicloud_ecs_snapshot
    group by
      region
    order by
      region;
  EOQ
}

query "alicloud_ecs_snapshot_storage_by_age" {
  sql = <<-EOQ
    with snapshots as (
      select
        title,
        CAST (source_disk_size AS INTEGER),
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        alicloud_ecs_snapshot
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
            (
              select
                min(creation_time)
                from snapshots)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    snapshots_by_month as (
      select
        creation_month,
        sum(CAST (source_disk_size AS INTEGER)) as size
      from
        snapshots
      group by
        creation_month
    )
    select
      months.month,
      snapshots_by_month.size as "GB"
    from
      months
      left join snapshots_by_month on months.month = snapshots_by_month.creation_month
    order by
      months.month;
  EOQ
}
