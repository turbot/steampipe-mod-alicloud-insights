dashboard "alicloud_ram_group_age_report" {

  title         = "Alicloud RAM Group Age Report"
  documentation = file("./dashboards/ram/docs/ram_group_report_age.md")

  tags = merge(local.ram_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.alicloud_ram_group_count
      width = 2
    }

    card {
      query = query.alicloud_ram_group_24_hours_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_group_30_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_group_30_90_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_group_90_365_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_group_1_year_count
      width = 2
      type  = "info"
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "ARN" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.alicloud_ram_group_detail.url_path}?input.group_title={{.Name | @uri}}"
    }

    query = query.alicloud_ram_group_age_table
  }

}

query "alicloud_ram_group_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      alicloud_ram_group
    where
      create_date > now() - '1 days' :: interval;
  EOQ
}

query "alicloud_ram_group_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      alicloud_ram_group
    where
      create_date between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "alicloud_ram_group_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      alicloud_ram_group
    where
      create_date between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "alicloud_ram_group_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      alicloud_ram_group
    where
      create_date between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "alicloud_ram_group_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      alicloud_ram_group
    where
      create_date <= now() - '1 year' :: interval;
  EOQ
}

query "alicloud_ram_group_age_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      now()::date - b.create_date::date as "Age in Days",
      b.create_date as "Create Time",
      a.title as "Account",
      b.account_id as "Account ID",
      b.region as "Region",
      b.akas ->> 0 as "ARN"
    from
      alicloud_ram_group as b,
      alicloud_account as a
    where
      b.account_id = a.account_id
    order by
      b.name;
  EOQ
}
