dashboard "ecs_disk_age_report" {

  title         = "AliCloud ECS Disk Age Report"
  documentation = file("./dashboards/ecs/docs/ecs_disk_report_age.md")

  tags = merge(local.ecs_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      width = 2
      query = query.ecs_disk_count
    }

    card {
      type  = "info"
      width = 2
      query = query.ecs_disk_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.ecs_disk_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.ecs_disk_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.ecs_disk_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.ecs_disk_1_year_count
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "ARN" {
      display = "none"
    }

    column "Disk ID" {
      href = "${dashboard.ecs_disk_detail.url_path}?input.disk_arn={{.ARN | @uri}}"
    }

    query = query.ecs_disk_age_table
  }

}

query "ecs_disk_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      alicloud_ecs_disk
    where
      creation_time > now() - '1 days' :: interval;
  EOQ
}

query "ecs_disk_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      alicloud_ecs_disk
    where
      creation_time between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "ecs_disk_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      alicloud_ecs_disk
    where
      creation_time between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "ecs_disk_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      alicloud_ecs_disk
    where
      creation_time between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "ecs_disk_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      alicloud_ecs_disk
    where
      creation_time <= now() - '1 year' :: interval;
  EOQ
}

query "ecs_disk_age_table" {
  sql = <<-EOQ
    select
      d.disk_id as "Disk ID",
      d.name as "Name",
      now()::date - d.creation_time::date as "Age in Days",
      d.creation_time as "Create Time",
      d.status as "State",
      a.title as "Account",
      d.account_id as "Account ID",
      d.region as "Region",
      d.arn as "ARN"
    from
      alicloud_ecs_disk as d,
      alicloud_account as a
    where
      d.account_id = a.account_id
    order by
      d.disk_id;
  EOQ
}
