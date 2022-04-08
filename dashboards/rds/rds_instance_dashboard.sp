dashboard "alicloud_rds_instance_dashboard" {

  title         = "AliCloud RDS Instance Dashboard"
  documentation = file("./dashboards/rds/docs/rds_instance_dashboard.md")

  tags = merge(local.rds_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.alicloud_rds_instance_count
      width = 2
    }

    card {
      query = query.alicloud_rds_instance_total_storage
      width = 2
    }

    # Assessments
    card {
      query = query.alicloud_rds_instance_ssl_count
      width = 2
    }

    card {
      query = query.alicloud_rds_instance_tde_count
      width = 2
    }

    card {
      query = query.alicloud_rds_instance_audit_count
      width = 2
    }

    card {
      query = query.alicloud_rds_instance_public_access_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "SSL Status"
      query = query.alicloud_rds_instance_by_ssl_status
      type  = "donut"
      width = 2

      series "Instances" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "TDE Status"
      query = query.alicloud_rds_instance_by_tde_status
      type  = "donut"
      width = 2

      series "Instances" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Audit Status"
      query = query.alicloud_rds_instance_by_audit_status
      type  = "donut"
      width = 2

      series "Instances" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Public Access"
      query = query.alicloud_rds_instance_by_public_access
      type  = "donut"
      width = 2

      series "Instances" {
        point "disabled" {
          color = "ok"
        }
        point "enabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Lock Mode"
      query = query.alicloud_rds_instance_by_lock_mode
      type  = "donut"
      width = 2

      series "Instances" {
        point "unlocked" {
          color = "ok"
        }
        point "locked" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Instances by Account"
      query = query.alicloud_rds_instance_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Region"
      query = query.alicloud_rds_instance_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by State"
      query = query.alicloud_rds_instance_by_state
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Age"
      query = query.alicloud_rds_instance_by_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Engine Type"
      query = query.alicloud_rds_instance_by_engine_type
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Class"
      query = query.alicloud_rds_instance_by_class
      type  = "column"
      width = 4
    }

  }

  container {

    title = "Performance & Utilization"
    width = 12

    chart {
      title = "Top 10 CPU - Last 7 days"
      query = query.alicloud_rds_instance_top10_cpu_past_week
      type  = "line"
      width = 6
    }

    chart {
      title = "Average max daily CPU - Last 30 days"
      query = query.alicloud_rds_instance_by_cpu_utilization_category
      type  = "column"
      width = 6
    }

  }

}

# Card Queries

query "alicloud_rds_instance_count" {
  sql = <<-EOQ
    select count(*) as "Instances" from alicloud_rds_instance;
  EOQ
}

query "alicloud_rds_instance_total_storage" {
  sql = <<-EOQ
    select sum(db_instance_storage) as "Total Storage(GB)" from alicloud_rds_instance;
  EOQ
}

query "alicloud_rds_instance_ssl_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'SSL Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      ssl_status = 'Disabled';
  EOQ
}

query "alicloud_rds_instance_tde_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'TDE Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      tde_status = 'Disabled';
  EOQ
}

query "alicloud_rds_instance_audit_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Audit Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      sql_collector_policy ->> 'SQLCollectorStatus' <> 'Enable';
  EOQ
}

query "alicloud_rds_instance_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Public Access' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      security_ips :: jsonb ? '0.0.0.0/0';
  EOQ
}

# Assessment Queries

query "alicloud_rds_instance_by_ssl_status" {
  sql = <<-EOQ
    select
      lower(ssl_status),
      count(*) as "Instances"
    from
      alicloud_rds_instance
    group by
      ssl_status
    order by
      ssl_status desc;
  EOQ
}

query "alicloud_rds_instance_by_tde_status" {
  sql = <<-EOQ
    select
      lower(tde_status),
      count(*) as "Instances"
    from
      alicloud_rds_instance
    group by
      tde_status
    order by
      tde_status desc;
  EOQ
}

query "alicloud_rds_instance_by_audit_status" {
  sql = <<-EOQ
    with db_instances as (
      select
        case
          when sql_collector_policy ->> 'SQLCollectorStatus' = 'Enable' then 'enabled'
          else 'disabled'
        end as audit_status
      from
        alicloud_rds_instance
    )
    select
      audit_status,
      count(*) as "Instances"
    from
      db_instances
    group by
      audit_status;
  EOQ
}

query "alicloud_rds_instance_by_public_access" {
  sql = <<-EOQ
    with db_instances as (
      select
        case
          when security_ips :: jsonb ? '0.0.0.0/0' then 'enabled'
          else 'disabled'
        end as public_access
      from
        alicloud_rds_instance
    )
    select
      public_access,
      count(*) as "Instances"
    from
      db_instances
    group by
      public_access;
  EOQ
}

query "alicloud_rds_instance_by_lock_mode" {
  sql = <<-EOQ
    with db_instances as (
      select
        case
          when lock_mode = 'Unlock'  then 'unlocked'
          else 'locked'
        end as lock
      from
        alicloud_rds_instance
    )
    select
      lock,
      count(*) as "Instances"
    from
      db_instances
    group by
      lock;
  EOQ
}

# Analysis Queries

query "alicloud_rds_instance_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(i.*) as "Instances"
    from
      alicloud_rds_instance as i,
      alicloud_account as a
    where
      a.account_id = i.account_id
    group by
      account
    order by count(i.*) desc;
  EOQ
}

query "alicloud_rds_instance_by_region" {
  sql = <<-EOQ
    select
      region,
      count(i.*) as Instances
    from
      alicloud_rds_instance as i
    group by
      region;
  EOQ
}

query "alicloud_rds_instance_by_state" {
  sql = <<-EOQ
    select
      db_instance_status,
      count(db_instance_status) as "Instances"
    from
      alicloud_rds_instance
    group by
      db_instance_status;
  EOQ
}

query "alicloud_rds_instance_by_creation_month" {
  sql = <<-EOQ
    with instances as (
      select
        title,
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        alicloud_rds_instance
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
                from instances)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    instances_by_month as (
      select
        creation_month,
        count(*)
      from
        instances
      group by
        creation_month
    )
    select
      months.month,
      instances_by_month.count as "Instances"
    from
      months
      left join instances_by_month on months.month = instances_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "alicloud_rds_instance_by_engine_type" {
  sql = <<-EOQ
    select engine as "Engine Type", count(*) as "Instances" from alicloud_rds_instance group by engine order by engine;
  EOQ
}

query "alicloud_rds_instance_by_class" {
  sql = <<-EOQ
    select
      db_instance_class,
      count(db_instance_class) as "Instances"
    from
      alicloud_rds_instance
    group by
      db_instance_class;
  EOQ
}

# Performance Queries

query "alicloud_rds_instance_top10_cpu_past_week" {
  sql = <<-EOQ
    with top_n as (
      select
        db_instance_id,
        avg(average)
      from
        alicloud_rds_instance_metric_cpu_utilization_daily
      where
        timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      group by
        db_instance_id
      order by
        avg desc
      limit 10
  )
  select
      timestamp,
      db_instance_id,
      average
    from
       alicloud_rds_instance_metric_cpu_utilization_hourly
    where
      timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      and db_instance_id in (select db_instance_id from top_n)
    order by
      timestamp;
  EOQ
}

query "alicloud_rds_instance_by_cpu_utilization_category" {
  sql = <<-EOQ
    with cpu_buckets as (
      select
    unnest(array ['Unused (<1%)','Underutilized (1-10%)','Right-sized (10-90%)', 'Overutilized (>90%)' ]) as cpu_bucket
    ),
    max_averages as (
      select
        db_instance_id,
        case
          when max(average) <= 1 then 'Unused (<1%)'
          when max(average) between 1 and 10 then 'Underutilized (1-10%)'
          when max(average) between 10 and 90 then 'Right-sized (10-90%)'
          when max(average) > 90 then 'Overutilized (>90%)'
        end as cpu_bucket,
        max(average) as max_avg
      from
        alicloud_rds_instance_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <= 30
      group by
        db_instance_id
    )
    select
      b.cpu_bucket as "CPU Utilization",
      count(a.*) as "Instances"
    from
      cpu_buckets as b
    left join max_averages as a on b.cpu_bucket = a.cpu_bucket
    group by
      b.cpu_bucket;
  EOQ
}
