dashboard "rds_instance_dashboard" {

  title         = "AliCloud RDS Instance Dashboard"
  documentation = file("./dashboards/rds/docs/rds_instance_dashboard.md")

  tags = merge(local.rds_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.rds_instance_count
      width = 2
    }

    # Assessments
    card {
      query = query.rds_instance_public_count
      width = 2
    }

    card {
      query = query.rds_instance_unencrypted_count
      width = 2

    }

    card {
      query = query.rds_instance_ssl_disabled_count
      width = 2

    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Public/Private Status"
      query = query.rds_instance_public_status
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
      query = query.rds_instance_by_encryption_status
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
      title = "SSL Status"
      query = query.rds_instance_ssl_status
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
      title = "Instances by Account"
      query = query.rds_instance_by_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Region"
      query = query.rds_instance_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Status"
      query = query.rds_instance_by_status
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Age"
      query = query.rds_instance_by_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Engine Type"
      query = query.rds_instance_by_engine_type
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Class"
      query = query.rds_instance_by_class
      type  = "column"
      width = 4
    }

  }

  container {

    title = "Performance & Utilization"
    width = 12

    chart {
      title = "Top 10 CPU - Last 7 days"
      query = query.rds_instance_top10_cpu_past_week
      type  = "line"
      width = 6
    }

    chart {
      title = "Average max daily CPU - Last 30 days"
      query = query.rds_instance_by_cpu_utilization_category
      type  = "column"
      width = 6
    }

  }

}

# Card Queries

query "rds_instance_count" {
  sql = <<-EOQ
    select count(*) as "RDS Instances" from alicloud_rds_instance
  EOQ
}

query "rds_instance_public_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      db_instance_net_type = 'Extranet';
  EOQ
}

query "rds_instance_unencrypted_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      tde_status = 'Disabled';
  EOQ
}

query "rds_instance_ssl_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'SSL' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_rds_instance
    where
      ssl_status = 'Disabled';
  EOQ
}

# Assessment Queries

query "rds_instance_public_status" {
  sql = <<-EOQ
    with db_instances as (
      select
        case
          when db_instance_net_type = 'Intranet' then 'private'
          else 'public'
        end as visibility
      from
        alicloud_rds_instance
    )
    select
      visibility,
      count(*)
    from
      db_instances
    group by
      visibility;
  EOQ
}

query "rds_instance_by_encryption_status" {
  sql = <<-EOQ
    select
      encryption_status,
      count(*)
    from (
      select
        case when tde_status = 'Enabled' then
          'enabled'
        else
          'disabled'
        end encryption_status
      from
        alicloud_rds_instance) as t
    group by
      encryption_status
    order by
      encryption_status desc;
  EOQ
}

query "rds_instance_ssl_status" {
  sql = <<-EOQ
    select
      ssl_status,
      count(*)
    from (
      select
        case when ssl_status = 'Enabled' then
          'enabled'
        else
          'disabled'
        end ssl_status
      from
        alicloud_rds_instance) as t
    group by
      ssl_status
    order by
      ssl_status desc;
  EOQ
}

# Analysis Queries

query "rds_instance_by_account" {
  sql = <<-EOQ
    select
      a.title as "Account",
      count(i.*) as "total"
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

query "rds_instance_by_region" {
  sql = <<-EOQ
    select
      region,
      count(i.*) as "total"
    from
      alicloud_rds_instance as i
    group by
      region;
  EOQ
}

query "rds_instance_by_status" {
  sql = <<-EOQ
    select
      db_instance_status,
      count(db_instance_status)
    from
      alicloud_rds_instance
    group by
      db_instance_status;
  EOQ
}

query "rds_instance_by_creation_month" {
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
      instances_by_month.count
    from
      months
      left join instances_by_month on months.month = instances_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "rds_instance_by_engine_type" {
  sql = <<-EOQ
    select engine as "Engine Type", count(*) as "instances" from alicloud_rds_instance group by engine order by engine;
  EOQ
}

query "rds_instance_by_class" {
  sql = <<-EOQ
    select
      db_instance_class,
      count(db_instance_class)
    from
      alicloud_rds_instance
    group by
      db_instance_class;
  EOQ
}

# Performance Queries

query "rds_instance_top10_cpu_past_week" {
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

query "rds_instance_by_cpu_utilization_category" {
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
      count(a.*)
    from
      cpu_buckets as b
    left join max_averages as a on b.cpu_bucket = a.cpu_bucket
    group by
      b.cpu_bucket;
  EOQ
}
