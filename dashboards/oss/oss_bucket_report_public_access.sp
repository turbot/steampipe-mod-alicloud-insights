dashboard "oss_bucket_public_access_report" {

  title         = "AliCloud OSS Bucket Public Access Report"
  documentation = file("./dashboards/oss/docs/oss_bucket_report_public_access.md")

  tags = merge(local.oss_common_tags, {
    type     = "Report"
    category = "Public Access"
  })

  container {

    card {
      query = query.oss_bucket_count
      width = 3
    }

    card {
      query = query.oss_bucket_public_access_not_blocked_count
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

    query = query.oss_bucket_public_access_table
  }

}

query "oss_bucket_public_access_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      b.acl as "ACL Access",
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
