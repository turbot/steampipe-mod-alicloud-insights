dashboard "oss_bucket_lifecycle_report" {

  title         = "AliCloud OSS Bucket Lifecycle Report"
  documentation = file("./dashboards/oss/docs/oss_bucket_report_lifecycle.md")

  tags = merge(local.oss_common_tags, {
    type     = "Report"
    category = "Lifecycle"
  })

  container {

    card {
      query = query.oss_bucket_count
      width = 3
    }

    card {
      query = query.oss_bucket_versioning_disabled_count
      width = 3
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

    query = query.oss_bucket_lifecycle_table
  }

}

query "oss_bucket_lifecycle_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      versioning as "Versioning",
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
