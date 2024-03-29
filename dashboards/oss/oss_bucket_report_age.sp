dashboard "oss_bucket_age_report" {

  title         = "AliCloud OSS Bucket Age Report"
  documentation = file("./dashboards/oss/docs/oss_bucket_report_age.md")

  tags = merge(local.oss_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.oss_bucket_count
      width = 2
    }

    card {
      query = query.oss_bucket_24_hours_count
      width = 2
      type  = "info"
    }

    card {
      query = query.oss_bucket_30_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.oss_bucket_30_90_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.oss_bucket_90_365_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.oss_bucket_1_year_count
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
      href = "${dashboard.oss_bucket_detail.url_path}?input.bucket_arn={{.ARN | @uri}}"
    }

    query = query.oss_bucket_age_table
  }

}

query "oss_bucket_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      alicloud_oss_bucket
    where
      creation_date > now() - '1 days' :: interval;
  EOQ
}

query "oss_bucket_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      alicloud_oss_bucket
    where
      creation_date between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "oss_bucket_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      alicloud_oss_bucket
    where
      creation_date between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "oss_bucket_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      alicloud_oss_bucket
    where
      creation_date between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "oss_bucket_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      alicloud_oss_bucket
    where
      creation_date <= now() - '1 year' :: interval;
  EOQ
}

query "oss_bucket_age_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      now()::date - b.creation_date::date as "Age in Days",
      b.creation_date as "Create Time",
      a.title as "Account",
      b.account_id as "Account ID",
      b.region as "Region",
      b.arn as "ARN"
    from
      alicloud_oss_bucket as b,
      alicloud_account as a
    where
      b.account_id = a.account_id
    order by
      b.creation_date,
      b.name;
  EOQ
}
