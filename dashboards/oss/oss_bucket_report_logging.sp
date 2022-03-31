dashboard "alicloud_oss_bucket_logging_report" {

  title         = "Alibaba Cloud OSS Bucket Logging Report"
  documentation = file("./dashboards/oss/docs/oss_bucket_report_logging.md")

  tags = merge(local.oss_common_tags, {
    type     = "Report"
    category = "Logging"
  })

  container {

    card {
      query = query.alicloud_oss_bucket_count
      width = 2
    }

    card {
      query = query.alicloud_oss_bucket_logging_disabled_count
      width = 2
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
      href = "${dashboard.alicloud_oss_bucket_detail.url_path}?input.bucket_arn={{.ARN | @uri}}"
    }

    query = query.alicloud_oss_bucket_logging_table
  }

}

query "alicloud_oss_bucket_logging_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      case when b.logging ->> 'TargetBucket' <> '' then 'Enabled' else null end as "Logging",
      b.logging ->> 'TargetBucket' as "Target Bucket",
      b.logging ->> 'TargetPrefix' as "Target Prefix",
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
      b.name;
  EOQ
}
