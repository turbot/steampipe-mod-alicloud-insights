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

    column "ARN" {
      display = "none"
    }

    column "User Name" {
      href = "${dashboard.alicloud_ram_user_detail.url_path}?input.user_arn={{.ARN | @uri}}"
    }

    query = query.alicloud_ram_user_mfa_table
  }

}

query "alicloud_ram_user_mfa_table" {
  sql = <<-EOQ
    select
      u.name as "User Name",
      u.arn as "ARN",
      mfa ->> 'SerialNumber' as "MFA Serial Number",
      case when u.mfa_enabled then 'Active' else null end as "MFA Status",
      mfa ->> 'ActivateDate' as "Activate Date",
      a.title as "Account",
      a.account_id as "Account ID"
    from
      alicloud_ram_user as u,
      alicloud_account as a,
      jsonb_array_elements(virtual_mfa_devices) as mfa
    where
      u.account_id = a.account_id
    order by
      u.mfa_enabled desc,
      u.name;
  EOQ
}
