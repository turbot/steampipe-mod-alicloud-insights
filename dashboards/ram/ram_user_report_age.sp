dashboard "alicloud_ram_user_age_report" {

  title         = "AliCloud RAM User Age Report"
  documentation = file("./dashboards/ram/docs/ram_user_report_age.md")

  tags = merge(local.ram_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.alicloud_ram_user_count
      width = 2
    }

    card {
      query = query.alicloud_ram_user_24_hours_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_user_30_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_user_30_90_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_user_90_365_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.alicloud_ram_user_1_year_count
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
      href = "${dashboard.alicloud_ram_user_detail.url_path}?input.user_arn={{.ARN | @uri}}"
    }

    query = query.alicloud_ram_user_age_table
  }

}

query "alicloud_ram_user_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      alicloud_ram_user
    where
      create_date > now() - '1 days' :: interval;
  EOQ
}

query "alicloud_ram_user_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      alicloud_ram_user
    where
      create_date between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "alicloud_ram_user_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      alicloud_ram_user
    where
      create_date between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "alicloud_ram_user_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      alicloud_ram_user
    where
      create_date between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "alicloud_ram_user_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      alicloud_ram_user
    where
      create_date <= now() - '1 year' :: interval;
  EOQ
}

query "alicloud_ram_user_age_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      b.arn as "ARN",
      now()::date - b.create_date::date as "Age in Days",
      b.create_date as "Create Time",
      a.title as "Account",
      b.account_id as "Account ID"
    from
      alicloud_ram_user as b,
      alicloud_account as a
    where
      b.account_id = a.account_id
    order by
      b.name;
  EOQ
}
