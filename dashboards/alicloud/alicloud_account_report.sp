dashboard "alicloud_account_report" {

  title         = "AliCloud Account Report"
  documentation = file("./dashboards/alicloud/docs/alicloud_account_report.md")

  tags = merge(local.alicloud_common_tags, {
    type     = "Report"
    category = "Accounts"
  })

  container {

    card {
      query   = query.alicloud_account_count
      width = 2
    }

  }

  table {
    column "ARN" {
      display = "none"
    }
    
    query = query.alicloud_account_table
  }

}

query "alicloud_account_count" {
  sql = <<-EOQ
    select
      count(*) as "Accounts"
    from
      alicloud_account;
  EOQ
}

query "alicloud_account_table" {
  sql = <<-EOQ
    select
      account_id as "Account ID",
      alias as "Alias",
      akas ->> 0 as "ARN"
    from
      alicloud_account;
  EOQ
}
