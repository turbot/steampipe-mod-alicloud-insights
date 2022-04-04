dashboard "alicloud_ecs_instance_dashboard" {

  title         = "Alicloud ECS Instance Dashboard"
  documentation = file("./dashboards/ecs/docs/ecs_instance_dashboard.md")

  tags = merge(local.ecs_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.alicloud_ecs_instance_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_instance_total_cores_count
      width = 2
    }

    # Assessments
    card {
      query = query.alicloud_ecs_instance_public_instance_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_instance_io_optimized_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_instance_deletion_protection_disabled_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Public/Private"
      query = query.alicloud_ecs_instance_by_public_ip
      type  = "donut"
      width = 3

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
      title = "I/O Optimized Status"
      query = query.alicloud_ecs_instance_by_io_optimized
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
      title = "Deletion Protection Status"
      query = query.alicloud_ecs_instance_by_deletion_protection
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

  }

  container {

    title = "Analysis"

    chart {
      title = "Instances by Account"
      query = query.alicloud_ecs_instance_by_account
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by Region"
      query = query.alicloud_ecs_instance_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by State"
      query = query.alicloud_ecs_instance_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by Age"
      query = query.alicloud_ecs_instance_by_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by Type"
      query = query.alicloud_ecs_instance_by_type
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by OS Type"
      query = query.alicloud_ecs_instance_by_os_type
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by Network Type"
      query = query.alicloud_ecs_instance_by_network_type
      type  = "column"
      width = 3
    }

  }

  container {

    title = "Performance & Utilization"

    chart {
      title = "Top 10 CPU - Last 7 days"
      query = query.alicloud_ecs_instance_top10_cpu_past_week
      type  = "line"
      width = 6
    }

    chart {
      title = "Average Max Daily CPU - Last 30 days"
      query = query.alicloud_ecs_instance_by_cpu_utilization_category
      type  = "column"
      width = 6
    }

  }

}

# Card Queries

query "alicloud_ecs_instance_count" {
  sql = <<-EOQ
    select count(*) as "Instances" from alicloud_ecs_instance;
  EOQ
}

query "alicloud_ecs_instance_total_cores_count" {
  sql = <<-EOQ
    select
      cpu_options_core_count as "Total Cores"
    from
      alicloud_ecs_instance;
  EOQ
}

query "alicloud_ecs_instance_public_instance_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_instance
    where
      jsonb_array_length(public_ip_address ) > 0;
  EOQ
}

query "alicloud_ecs_instance_io_optimized_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'I/O Not Optimized' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_instance
    where
      not io_optimized;
  EOQ
}

query "alicloud_ecs_instance_deletion_protection_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Deletion Protection Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_instance
    where
      not deletion_protection;
  EOQ
}

# Assessment Queries

query "alicloud_ecs_instance_by_public_ip" {
  sql = <<-EOQ
    with instances as (
      select
        case
          when jsonb_array_length(public_ip_address) = 0 then 'private'
          else 'public'
        end as state
      from
        alicloud_ecs_instance
    )
    select
      state,
      count(*)
    from
      instances
    group by
      state;
  EOQ
}

query "alicloud_ecs_instance_by_io_optimized" {
  sql = <<-EOQ
    with instances as (
      select
        case
          when io_optimized then 'enabled'
          else 'disabled'
        end as state
      from
        alicloud_ecs_instance
    )
    select
      state,
      count(*)
    from
      instances
    group by
      state;
  EOQ
}

query "alicloud_ecs_instance_by_deletion_protection" {
  sql = <<-EOQ
    with instances as (
      select
        case
          when deletion_protection then 'enabled'
          else 'disabled'
        end as state
      from
        alicloud_ecs_instance
    )
    select
      state,
      count(*)
    from
      instances
    group by
      state;
  EOQ
}

# Analysis Queries

query "alicloud_ecs_instance_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(i.*) as "total"
    from
      alicloud_ecs_instance as i,
      alicloud_account as a
    where
      a.account_id = i.account_id
    group by
      account
    order by count(i.*) desc;
  EOQ
}

query "alicloud_ecs_instance_by_region" {
  sql = <<-EOQ
    select
      region,
      count(i.*) as "total"
    from
      alicloud_ecs_instance as i
    group by
      region;
  EOQ
}

query "alicloud_ecs_instance_by_state" {
  sql = <<-EOQ
    select
      status,
      count(status) as "total"
    from
      alicloud_ecs_instance
    group by
      status;
  EOQ
}

query "alicloud_ecs_instance_by_creation_month" {
  sql = <<-EOQ
    with instances as (
      select
        title,
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        alicloud_ecs_instance
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
      instances_by_month.count as "total"
    from
      months
      left join instances_by_month on months.month = instances_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "alicloud_ecs_instance_by_type" {
  sql = <<-EOQ
    select
      instance_type as "Type",
      count(*) as "total"
    from
      alicloud_ecs_instance
    group by
      instance_type
    order by
      instance_type;
  EOQ
}

query "alicloud_ecs_instance_by_os_type" {
  sql = <<-EOQ
    select
      os_type as "Type",
      count(*) as "total"
    from
      alicloud_ecs_instance
    group by
      os_type
    order by
      os_type;
  EOQ
}

query "alicloud_ecs_instance_by_network_type" {
  sql = <<-EOQ
    select
      instance_network_type as "Type",
      count(*) as "total"
    from
      alicloud_ecs_instance
    group by
      instance_network_type
    order by
      instance_network_type;
  EOQ
}

# Performance Queries

query "alicloud_ecs_instance_top10_cpu_past_week" {
  sql = <<-EOQ
    with top_n as (
      select
        instance_id,
        avg(average)
      from
        alicloud_ecs_instance_metric_cpu_utilization_daily
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
      alicloud_ecs_instance_metric_cpu_utilization_hourly
    where
      timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      and instance_id in (select instance_id from top_n)
    order by
      timestamp;
  EOQ
}

# underused if avg CPU < 10% every day for last month
query "alicloud_ecs_instance_by_cpu_utilization_category" {
  sql = <<-EOQ
    with cpu_buckets as (
      select
    unnest(array ['Unused (<1%)','Underutilized (1-10%)','Right-sized (10-90%)', 'Overutilized (>90%)' ]) as cpu_bucket
    ),
    max_averages as (
      select
        instance_id,
        case
          when max(average) <= 1 then 'Unused (<1%)'
          when max(average) between 1 and 10 then 'Underutilized (1-10%)'
          when max(average) between 10 and 90 then 'Right-sized (10-90%)'
          when max(average) > 90 then 'Overutilized (>90%)'
        end as cpu_bucket,
        max(average) as max_avg
      from
        alicloud_ecs_instance_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <= 30
      group by
        instance_id
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
