dashboard "alicloud_oss_bucket_public_access_report" {

  title = "Alibaba Cloud OSS Bucket Public Access Report"

  tags = merge(local.oss_common_tags, {
    type     = "Report"
    category = "Public Access"
  })

  container {

    card {
      query = query.alicloud_oss_bucket_count
      width = 2
    }

    card {
      query = query.alicloud_oss_bucket_public_access_not_blocked_count
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

    query = query.alicloud_oss_bucket_public_access_table
  }

}

query "alicloud_oss_bucket_public_access_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      b.acl as "Access",
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
