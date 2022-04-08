dashboard "alicloud_ecs_disk_encryption_report" {

  title         = "AliCloud ECS Disk Encryption Report"
  documentation = file("./dashboards/ecs/docs/ecs_disk_report_encryption.md")

  tags = merge(local.ecs_common_tags, {
    type     = "Report"
    category = "Encryption"
  })

  container {

    card {
      query = query.alicloud_ecs_disk_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_disk_unencrypted_count
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

    column "Disk ID" {
      href = "${dashboard.alicloud_ecs_disk_detail.url_path}?input.disk_arn={{.ARN | @uri}}"
    }

    query = query.alicloud_ecs_disk_encryption_table
  }

}

query "alicloud_ecs_disk_encryption_table" {
  sql = <<-EOQ
    select
      d.disk_id as "Disk ID",
      d.name as "Name",
      case when d.encrypted then 'Enabled' else null end as "Encryption",
      d.kms_key_id as "KMS Key ID",
      a.title as "Account",
      d.account_id as "Account ID",
      d.region as "Region",
      d.arn as "ARN"
    from
      alicloud_ecs_disk as d,
      alicloud_account as a
    where
      d.account_id = a.account_id
    order by
      d.disk_id;
  EOQ
}
