dashboard "ecs_instance_age_report" {

  title         = "AliCloud ECS Instance Age Report"
  documentation = file("./dashboards/ecs/docs/ecs_instance_report_age.md")

  tags = merge(local.ecs_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.ecs_instance_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.ecs_instance_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.ecs_instance_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.ecs_instance_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.ecs_instance_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.ecs_instance_1_year_count
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "ARN" {
      display = "none"
    }

    column "Instance ID" {
      href = "${dashboard.ecs_instance_detail.url_path}?input.instance_arn={{.ARN | @uri}}"
    }

    query = query.ecs_instance_age_table
  }

}

query "ecs_instance_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      alicloud_ecs_instance
    where
      start_time > now() - '1 days' :: interval;
  EOQ
}

query "ecs_instance_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      alicloud_ecs_instance
    where
      start_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "ecs_instance_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      alicloud_ecs_instance
    where
      start_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "ecs_instance_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      alicloud_ecs_instance
    where
      start_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "ecs_instance_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      alicloud_ecs_instance
    where
      start_time <= now() - '1 year' :: interval;
  EOQ
}

query "ecs_instance_age_table" {
  sql = <<-EOQ
    select
      i.tags ->> 'Name' as "Name",
      i.instance_id as "Instance ID",
      now()::date - i.start_time::date as "Age in Days",
      i.start_time as "Start Time",
      i.status as "State",
      a.title as "Account",
      i.account_id as "Account ID",
      i.region as "Region",
      i.arn as "ARN"
    from
      alicloud_ecs_instance as i,
      alicloud_account as a
    where
      i.account_id = a.account_id
    order by
      i.start_time,
      i.tags ->> 'Name';
  EOQ
}
