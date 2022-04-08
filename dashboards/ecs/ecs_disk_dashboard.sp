dashboard "alicloud_ecs_disk_dashboard" {

  title         = "AliCloud ECS Disk Dashboard"
  documentation = file("./dashboards/ecs/docs/ecs_disk_dashboard.md")

  tags = merge(local.ecs_common_tags, {
    type = "Dashboard"
  })

  container {
    # Analysis
    card {
      query = query.alicloud_ecs_disk_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_disk_storage_total
      width = 2
    }

    # Assessments
    card {
      query = query.alicloud_ecs_disk_unattached_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_disk_unencrypted_count
      width = 2
      href  = dashboard.alicloud_ecs_disk_encryption_report.url_path
    }

    card {
      query = query.alicloud_ecs_disk_delete_auto_snapshot_count
      width = 3
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Disk Status"
      query = query.alicloud_ecs_disk_by_status
      type  = "donut"
      width = 4

      series "Disks" {
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
      query = query.alicloud_ecs_disk_by_encryption_status
      type  = "donut"
      width = 4

      series "Disks" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Auto Snapshot Deletion"
      query = query.alicloud_ecs_disk_auto_snapshot_deletion
      type  = "donut"
      width = 4

      series "Disks" {
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
      title = "Disks by Account"
      query = query.alicloud_ecs_disk_by_account
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Region"
      query = query.alicloud_ecs_disk_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Category"
      query = query.alicloud_ecs_disk_by_category
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Age"
      query = query.alicloud_ecs_disk_by_creation_month
      type  = "column"
      width = 3
    }

  }

  container {

    chart {
      title = "Storage by Account (GB)"
      query = query.alicloud_ecs_disk_storage_by_account
      type  = "column"
      width = 3

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Region (GB)"
      query = query.alicloud_ecs_disk_storage_by_region
      type  = "column"
      width = 3

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Category (GB)"
      query = query.alicloud_ecs_disk_storage_by_category
      type  = "column"
      width = 3

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Age (GB)"
      query = query.alicloud_ecs_disk_storage_by_creation_month
      type  = "column"
      width = 3

      series "GB" {
        color = "tan"
      }
    }

  }

  container {

    title = "Performance & Utilization"

    chart {
      title = "Top 10 Average Read IOPS - Last 7 days"
      type  = "line"
      width = 6
      query = query.alicloud_ecs_disk_top_10_read_ops_avg
    }

    chart {
      title = "Top 10 Average Write IOPS - Last 7 days"
      type  = "line"
      width = 6
      query = query.alicloud_ecs_disk_top_10_write_ops_avg
    }

  }

}

# Card Queries

query "alicloud_ecs_disk_count" {
  sql = <<-EOQ
    select count(*) as "Disks" from alicloud_ecs_disk
  EOQ
}

query "alicloud_ecs_disk_storage_total" {
  sql = <<-EOQ
    select
      sum(size) as "Total Storage (GB)"
    from
      alicloud_ecs_disk;
  EOQ
}

query "alicloud_ecs_disk_unattached_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unused' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_disk
    where
      status <> 'In_use';
  EOQ
}

query "alicloud_ecs_disk_unencrypted_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrpted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_disk
    where
      not encrypted;
  EOQ
}

query "alicloud_ecs_disk_delete_auto_snapshot_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Auto Snapshot Deletion Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_disk
    where
      enable_auto_snapshot and
      not delete_auto_snapshot;
  EOQ
}

# Assessments Queries

query "alicloud_ecs_disk_by_status" {
  sql = <<-EOQ
    select
        usage_status,
        count(*) as "Disks"
    from (
        select status,
        case when status = 'In_use' then
            'in-use'
        else
            'unused'
        end usage_status
    from
        alicloud_ecs_disk) as t
    group by
        usage_status
    order by
        usage_status desc;
  EOQ
}

query "alicloud_ecs_disk_by_encryption_status" {
  sql = <<-EOQ
    select
        encryption_status,
        count(*) as "Disks"
    from (
        select encrypted,
        case when encrypted then
            'enabled'
        else
            'disabled'
        end encryption_status
    from
        alicloud_ecs_disk) as t
    group by
        encryption_status
    order by
        encryption_status desc;
  EOQ
}

query "alicloud_ecs_disk_auto_snapshot_deletion" {
  sql = <<-EOQ
    select
        delete_auto_snapshot_enabled,
        count(*) as "Disks"
    from (
        select
            delete_auto_snapshot,
        case when delete_auto_snapshot then
            'enabled'
        else
            'disabled'
        end delete_auto_snapshot_enabled
    from
        alicloud_ecs_disk
    where
        enable_auto_snapshot) as t
    group by
        delete_auto_snapshot_enabled
    order by
        delete_auto_snapshot_enabled desc;
  EOQ
}

# Analysis Queries

query "alicloud_ecs_disk_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(v.*) as "Disks"
    from
      alicloud_ecs_disk as v,
      alicloud_account as a
    where
      a.account_id = v.account_id
    group by
      account
    order by
      account;
  EOQ
}

query "alicloud_ecs_disk_by_region" {
  sql = <<-EOQ
    select
      region as "Region",
      count(*) as "Disks"
    from
      alicloud_ecs_disk
    group by
      region
    order by
      region;
  EOQ
}

query "alicloud_ecs_disk_by_category" {
  sql = <<-EOQ
    select
      category as "Category",
      count(*) as "Disks"
    from
      alicloud_ecs_disk
    group by
      category
    order by
      category;
  EOQ
}

query "alicloud_ecs_disk_by_creation_month" {
  sql = <<-EOQ
    with disks as (
      select
        title,
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        alicloud_ecs_disk
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
                from disks)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    disks_by_month as (
      select
        creation_month,
        count(*)
      from
        disks
      group by
        creation_month
    )
    select
      months.month,
      disks_by_month.count as "Disks"
    from
      months
      left join disks_by_month on months.month = disks_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "alicloud_ecs_disk_storage_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      sum(v.size) as "GB"
    from
      alicloud_ecs_disk as v,
      alicloud_account as a
    where
      a.account_id = v.account_id
    group by
      account
    order by
      account;
  EOQ
}

query "alicloud_ecs_disk_storage_by_region" {
  sql = <<-EOQ
    select
      region as "Region",
      sum(size) as "GB"
    from
      alicloud_ecs_disk
    group by
      region
    order by
      region;
  EOQ
}

query "alicloud_ecs_disk_storage_by_category" {
  sql = <<-EOQ
    select
      category,
      sum(size) as "GB"
    from
      alicloud_ecs_disk
    group by
      category
    order by
      category;
  EOQ
}

query "alicloud_ecs_disk_storage_by_creation_month" {
  sql = <<-EOQ
    with disks as (
      select
        title,
        size,
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        alicloud_ecs_disk
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
                from disks)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    disks_by_month as (
      select
        creation_month,
        sum(size) as size
      from
        disks
      group by
        creation_month
    )
    select
      months.month,
      disks_by_month.size as "GB"
    from
      months
      left join disks_by_month on months.month = disks_by_month.creation_month
    order by
      months.month;
  EOQ
}

# Performance Queries

query "alicloud_ecs_disk_top_10_read_ops_avg" {
  sql = <<-EOQ
    with top_n as (
      select
        instance_id,
        avg(average)
      from
        alicloud_ecs_disk_metric_read_iops_daily
      where
        timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      group by
        instance_id
      order by
        avg desc
      limit 10
    )
    select
        timestamp,
        instance_id,
        average
      from
        alicloud_ecs_disk_metric_read_iops_hourly
      where
        timestamp  >= CURRENT_DATE - INTERVAL '7 day'
        and instance_id in (select instance_id from top_n);
  EOQ
}

query "alicloud_ecs_disk_top_10_write_ops_avg" {
  sql = <<-EOQ
    with top_n as (
      select
        instance_id,
        avg(average)
      from
        alicloud_ecs_disk_metric_write_iops_daily
      where
        timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      group by
        instance_id
      order by
        avg desc
      limit 10
    )
    select
      timestamp,
      instance_id,
      average
    from
      alicloud_ecs_disk_metric_write_iops_hourly
    where
      timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      and instance_id in (select instance_id from top_n);
  EOQ
}
