dashboard "alicloud_kms_key_lifecycle_report" {

  title         = "Alibaba Cloud CMK Lifecycle Report"
  documentation = file("./dashboards/kms/docs/kms_key_report_lifecycle.md")

  tags = merge(local.kms_common_tags, {
    type     = "Report"
    category = "Lifecycle"
  })

  container {

    card {
      sql   = query.alicloud_kms_customer_managed_key_count.sql
      width = 2
    }

    card {
      sql = query.alicloud_kms_key_rotation_disabled_count.sql
      width = 2
    }

    card {
      sql = query.alicloud_kms_cmk_pending_deletion_count.sql
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

      column "Key ID" {
        href = "${dashboard.alicloud_kms_key_detail.url_path}?input.key_arn={{.ARN | @uri}}"
      }

      sql = query.alicloud_kms_cmk_lifecycle_table.sql
    }

}

query "alicloud_kms_key_rotation_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Rotation Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      automatic_rotation = 'Disabled'
      --and key_manager = 'CUSTOMER';
  EOQ
}

query "alicloud_kms_cmk_pending_deletion_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Pending Deletion' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      alicloud_kms_key
    where
      key_state = 'PendingDeletion'
      --and key_manager = 'CUSTOMER';
  EOQ
}

query "alicloud_kms_cmk_lifecycle_table" {
  sql = <<-EOQ
    select
      k.key_id as "Key ID",
      k.automatic_rotation as "Key Rotation",
      k.key_state as "Key State",
      --k.key_manager as "Key Manager",
      k.delete_date as "Deletion Date",
      a.title as "Account",
      k.account_id as "Account ID",
      k.region as "Region",
      k.arn as "ARN"
    from
      alicloud_kms_key as k,
      alicloud_account as a
    where
      k.account_id = a.account_id
      --and k.key_manager = 'CUSTOMER'
    order by
      k.key_id;
  EOQ
}