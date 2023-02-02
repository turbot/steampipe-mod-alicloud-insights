dashboard "kms_key_lifecycle_report" {

  title         = "AliCloud KMS CMK Lifecycle Report"
  documentation = file("./dashboards/kms/docs/kms_key_report_lifecycle.md")

  tags = merge(local.kms_common_tags, {
    type     = "Report"
    category = "Lifecycle"
  })

  container {

    card {
      query = query.kms_key_rotation_disabled_count
      width = 3
    }

    card {
      query = query.kms_cmk_pending_deletion_count
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

    column "Key ID" {
      href = "${dashboard.kms_key_detail.url_path}?input.key_arn={{.ARN | @uri}}"
    }

    query = query.kms_cmk_lifecycle_table
  }

}

query "kms_key_rotation_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Rotation Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      automatic_rotation = 'Disabled';
  EOQ
}

query "kms_cmk_pending_deletion_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Pending Deletion' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      alicloud_kms_key
    where
      key_state = 'PendingDeletion';
  EOQ
}

query "kms_cmk_lifecycle_table" {
  sql = <<-EOQ
    select
      k.key_id as "Key ID",
      k.automatic_rotation as "Key Rotation",
      k.key_state as "Key State",
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
    order by
      k.key_id;
  EOQ
}
