dashboard "alicloud_ram_credential_report" {

  title = "Alicloud RAM Credential Report"
  documentation = file("./dashboards/ram/docs/ram_credential_report.md")

  tags = merge(local.ram_common_tags, {
    type     = "Report"
    category = "Credential Report"
  })

  text {
    value = <<-EOT
    ## Note
    This report requires an [Alicloud Credential Report](https://partners-intl.aliyun.com/help/en/resource-access-management/latest/generate-and-download-user-credential-reports) for each account.
    You can generate a credential report via the Aliyun CLI:
    EOT
  }

  text {
    width = 3
    value = <<-EOT
    ```bash
    aliyun ims GenerateCredentialReport --endpoint ims.aliyuncs.com
    ```
    EOT
  }

  table {

    column "Account ID" {
      display = "none"
    }

    column "User ARN" {
      display = "none"
    }

    column "User Name" {
      href = "${dashboard.alicloud_ram_user_detail.url_path}?input.user_arn={{.'User ARN' | @uri}}"
    }

    query = query.alicloud_ram_credential_entities_root_access_keys_table
  }

}

# Card Queries

query "alicloud_ram_credential_entities_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Total Entities' as label
    from
      alicloud_ram_credential_report;
  EOQ
}

query "alicloud_ram_credential_entities_console_access_with_no_mfa_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Console Access and No MFA' as label,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      alicloud_ram_credential_report
    where
      password_active
      and not mfa_active;
  EOQ
}

query "alicloud_ram_credential_entities_root_access_keys_table" {
  sql = <<-EOQ
    select
      user_name as "User Name",
      'acs:ram::' || r.account_id || ':user/' || user_name as "User ARN",

      password_exist as "Password Enabled",
      mfa_active as "MFA Active",
      password_active as "Password Status",
      now()::date - password_last_changed::date as "Password Age in Days",
      password_last_changed as "Password Changed Timestamp",
      date_trunc('day',age(now(),user_last_logon))::text as "Password Last Used",
      user_last_logon as "Password Last Used Timestamp",
      date_trunc('day',age(now(),password_next_rotation))::text as "Next Password Rotation",
      password_next_rotation "Next Password Rotation Timestamp",

      access_key_1_active as "Access Key 1 Active",
      now()::date - access_key_1_last_rotated::date as "Key 1 Age in Days",
      access_key_1_last_rotated as "Key 1 Last Rotated",
      date_trunc('day',age(now(),access_key_1_last_used))::text as  "Key 1 Last Used",
      access_key_1_last_used as "Key 1 Last Used Timestamp",

      access_key_2_active as "Access Key 2 Active",
      now()::date - access_key_2_last_rotated::date as "Key 2 Age in Days",
      access_key_2_last_rotated as "Key 2 Last Rotated Timestamp",
      date_trunc('day',age(now(),access_key_2_last_used))::text as  "Key 2 Last Used",
      access_key_2_last_used as "Key 2 Last Used Timestamp",

      a.title as "Account",
      r.account_id as "Account ID"

    from
      alicloud_ram_credential_report as r,
      alicloud_account as a
    where
      a.account_id = r.account_id
    order by
      user_name;
  EOQ
}
