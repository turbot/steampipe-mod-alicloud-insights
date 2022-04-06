dashboard "alicloud_ram_user_mfa_report" {

  title         = "Alicloud RAM User MFA Report"
  documentation = file("./dashboards/ram/docs/ram_user_report_mfa.md")

  tags = merge(local.ram_common_tags, {
    type     = "Report"
    category = "Security"
  })

  container {

    card {
      query = query.alicloud_ram_user_count
      width = 2
    }

    card {
      query = query.alicloud_ram_user_no_mfa_count
      width = 2
    }
  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "User Name" {
      href = "${dashboard.alicloud_ram_user_detail.url_path}?input.user_aka={{.ARN | @uri}}"
    }

    query = query.alicloud_ram_user_mfa_table
  }

}

query "alicloud_ram_user_mfa_table" {
  sql = <<-EOQ
    select
      u.name as "User Name",
      case when u.mfa_enabled then 'Active' else null end as "MFA Status",
      a.title as "Account",
      a.account_id as "Account ID",
      u.akas ->> 0 as "ARN"
    from
      alicloud_ram_user as u,
      alicloud_account as a
    where
      u.account_id = a.account_id
    order by
      u.mfa_enabled desc,
      u.name;
  EOQ
}
