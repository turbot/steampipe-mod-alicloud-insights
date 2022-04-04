dashboard "alicloud_ecs_disk_detail" {

  title         = "Alicloud ECS Disk Detail"
  documentation = file("./dashboards/ecs/docs/ecs_disk_detail.md")

  tags = merge(local.ecs_common_tags, {
    type = "Detail"
  })

  input "disk_arn" {
    title = "Select a disk:"
    query = query.alicloud_ecs_disk_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.alicloud_ecs_disk_storage
      args = {
        arn = self.input.disk_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ecs_disk_iops
      args = {
        arn = self.input.disk_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ecs_disk_category
      args = {
        arn = self.input.disk_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ecs_disk_attached_instances_count
      args = {
        arn = self.input.disk_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_ecs_disk_encryption
      args = {
        arn = self.input.disk_arn.value
      }
    }

  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.alicloud_ecs_disk_overview
        args = {
          arn = self.input.disk_arn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.alicloud_ecs_disk_tags
        args = {
          arn = self.input.disk_arn.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.alicloud_ecs_disk_attached_instances
        args = {
          arn = self.input.disk_arn.value
        }

        column "Instance ARN" {
          display = "none"
        }

        column "Instance ID" {
          display = "none"
        }
        # {
        #   href = "${dashboard.alicloud_ecs_instance_detail.url_path}?input.instance_arn={{.'Instance ARN' | @uri}}"
        # }
      }

      table {
        title = "Encryption Details"
        column "KMS Key ID" {
          href = "${dashboard.alicloud_kms_key_detail.url_path}?input.key_arn={{.'KMS Key ID' | @uri}}"
        }
        query = query.alicloud_ecs_disk_encryption_status
        args = {
          arn = self.input.disk_arn.value
        }
      }
    }
  }

  container {

    width = 12

    chart {
      title = "Read Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      sql   = <<-EOQ
        select
          timestamp,
          (average / 3600) as read_throughput_ops
        from
          alicloud_ecs_disk_metric_read_iops_hourly
        where
          timestamp >= current_date - interval '7 day'
          and instance_id = reverse(split_part(reverse($1), '/', 1))
        order by timestamp
      EOQ

      param "arn" {}

      args = {
        arn = self.input.disk_arn.value
      }
    }

    chart {
      title = "Write Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      sql   = <<-EOQ
        select
          timestamp,
          (average / 3600) as write_throughput_ops
        from
          alicloud_ecs_disk_metric_write_iops_hourly
        where
          timestamp >= current_date - interval '7 day'
          and instance_id = reverse(split_part(reverse($1), '/', 1))
        order by timestamp;
      EOQ

      param "arn" {}

      args = {
        arn = self.input.disk_arn.value
      }
    }

  }

}

query "alicloud_ecs_disk_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'disk_id', disk_id
      ) as tags
    from
      alicloud_ecs_disk
    order by
      title;
  EOQ
}

query "alicloud_ecs_disk_storage" {
  sql = <<-EOQ
    select
      'Storage (GB)' as label,
      sum(size) as value
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_iops" {
  sql = <<-EOQ
    select
      'IOPS' as label,
      iops as value
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_category" {
  sql = <<-EOQ
    select
      'Category' as label,
      category as value
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_attached_instances_count" {
  sql = <<-EOQ
    select
      'Attached Instances' as label,
      case
        when attachments is null then 0
        else jsonb_array_length(attachments)
      end as value,
      case
        when jsonb_array_length(attachments) > 0 then 'ok'
        else 'alert'
      end as "type"
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when encrypted then 'Enabled' else 'Disabled' end as value,
      case when encrypted then 'ok' else 'alert' end as type
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_attached_instances" {
  sql = <<-EOQ
    select
      i.instance_id as "Instance ID",
      i.name as "Name",
      i.arn as "Instance ARN",
      i.status as "Instance State",
      attachment ->> 'AttachedTime' as "Attachment Time"
    from
      alicloud_ecs_disk as v,
      jsonb_array_elements(attachments) as attachment,
      alicloud_ecs_instance as i
    where
      i.instance_id = attachment ->> 'InstanceId'
      and v.arn = $1
    order by
      i.instance_id;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_encryption_status" {
  sql = <<-EOQ
    select
      case when encrypted then 'Enabled' else 'Disabled' end as "Encryption",
      kms_key_id as "KMS Key ID"
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_overview" {
  sql = <<-EOQ
    select
      disk_id as "Disk ID",
      enable_auto_snapshot as "Auto Enabled Snapshot",
      source_snapshot_id as "Snapshot ID",
      zone as "Zone",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_ecs_disk
    where
      arn = $1
  EOQ

  param "arn" {}
}

query "alicloud_ecs_disk_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      alicloud_ecs_disk,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'Key';
  EOQ

  param "arn" {}
}
