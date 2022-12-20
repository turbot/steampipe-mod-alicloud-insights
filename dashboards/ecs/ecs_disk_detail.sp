dashboard "ecs_disk_detail" {

  title         = "AliCloud ECS Disk Detail"
  documentation = file("./dashboards/ecs/docs/ecs_disk_detail.md")

  tags = merge(local.ecs_common_tags, {
    type = "Detail"
  })

  input "disk_arn" {
    title = "Select a disk:"
    query = query.ecs_disk_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.ecs_disk_storage
      args  = [self.input.disk_arn.value]
    }

    card {
      width = 2
      query = query.ecs_disk_iops
      args  = [self.input.disk_arn.value]
    }

    card {
      width = 2
      query = query.ecs_disk_category
      args  = [self.input.disk_arn.value]
    }

    card {
      width = 2
      query = query.ecs_disk_attached_instances_count
      args  = [self.input.disk_arn.value]
    }

    card {
      width = 2
      query = query.ecs_disk_encryption
      args  = [self.input.disk_arn.value]
    }

  }

  with "from_ecs_snapshots" {
    query = query.ecs_disk_from_ecs_snapshots
    args  = [self.input.disk_arn.value]
  }

  with "to_ecs_snapshots" {
    query = query.ecs_disk_to_ecs_snapshots
    args  = [self.input.disk_arn.value]
  }

  with "ecs_images" {
    query = query.ecs_disk_ecs_images
    args  = [self.input.disk_arn.value]
  }

  with "ecs_instances" {
    query = query.ecs_disk_ecs_instances
    args  = [self.input.disk_arn.value]
  }

  with "kms_keys" {
    query = query.ecs_disk_kms_keys
    args  = [self.input.disk_arn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ecs_snapshot
        args = {
          ecs_snapshot_arns = with.from_ecs_snapshots.rows[*].snapshot_arn
        }
      }

      node {
        base = node.ecs_snapshot
        args = {
          ecs_snapshot_arns = with.to_ecs_snapshots.rows[*].snapshot_arn
        }
      }

      node {
        base = node.ecs_disk
        args = {
          ecs_disk_arns = [self.input.disk_arn.value]
        }
      }

      node {
        base = node.ecs_image
        args = {
          ecs_image_ids = with.ecs_images.rows[*].image_id
        }
      }

      node {
        base = node.ecs_instance
        args = {
          ecs_instance_arns = with.ecs_instances.rows[*].instance_arn
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_arns = with.kms_keys.rows[*].key_arn
        }
      }

      edge {
        base = edge.ecs_disk_to_ecs_image
        args = {
          ecs_disk_arns = [self.input.disk_arn.value]
        }
      }

      edge {
        base = edge.ecs_disk_to_ecs_snapshot
        args = {
          ecs_snapshot_arns = with.to_ecs_snapshots.rows[*].snapshot_arn
        }
      }

      edge {
        base = edge.ecs_snapshot_to_disk
        args = {
          ecs_snapshot_arns = with.from_ecs_snapshots.rows[*].snapshot_arn
        }
      }

      edge {
        base = edge.ecs_disk_to_kms_key
        args = {
          ecs_disk_arns = [self.input.disk_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_ecs_disk
        args = {
          ecs_instance_arns = with.ecs_instances.rows[*].instance_arn
        }
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
        query = query.ecs_disk_overview
        args  = [self.input.disk_arn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.ecs_disk_tags
        args  = [self.input.disk_arn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.ecs_disk_attached_instances
        args  = [self.input.disk_arn.value]

        column "Instance ARN" {
          display = "none"
        }

        column "Instance ID" {
          href = "${dashboard.ecs_instance_detail.url_path}?input.instance_arn={{.'Instance ARN' | @uri}}"
        }
      }

      table {
        title = "Encryption Details"
        column "KMS Key ID" {
          href = "${dashboard.kms_key_detail.url_path}?input.key_arn={{.'KMS Key ID' | @uri}}"
        }
        query = query.ecs_disk_encryption_status
        args  = [self.input.disk_arn.value]
      }
    }
  }

}

query "ecs_disk_input" {
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

# card queries

query "ecs_disk_storage" {
  sql = <<-EOQ
    select
      'Storage (GB)' as label,
      sum(size) as value
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

}

query "ecs_disk_iops" {
  sql = <<-EOQ
    select
      'IOPS' as label,
      iops as value
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

}

query "ecs_disk_category" {
  sql = <<-EOQ
    select
      'Category' as label,
      category as value
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

}

query "ecs_disk_attached_instances_count" {
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

}

query "ecs_disk_encryption" {
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

}

# with queries

query "ecs_disk_from_ecs_snapshots" {
  sql = <<-EOQ
    select
      s.arn as snapshot_arn
    from
      alicloud_ecs_snapshot s
      left join alicloud_ecs_disk as d on s.snapshot_id = d.source_snapshot_id
    where
      d.arn = $1
      and s.arn is not null;
  EOQ
}

query "ecs_disk_to_ecs_snapshots" {
  sql = <<-EOQ
    select
      s.arn as snapshot_arn
    from
      alicloud_ecs_snapshot s
      left join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
    where
      d.arn = $1
      and s.arn is not null;
  EOQ
}

query "ecs_disk_ecs_images" {
  sql = <<-EOQ
    select
      image_id as image_id
    from
      alicloud_ecs_disk
    where
      arn = $1
      and image_id is not null;
  EOQ
}

query "ecs_disk_ecs_instances" {
  sql = <<-EOQ
    select
      i.arn as instance_arn
    from
      alicloud_ecs_instance i
      left join alicloud_ecs_disk as d on i.instance_id = d.instance_id
    where
      d.arn = $1
      and i.arn is not null;
  EOQ
}

query "ecs_disk_kms_keys" {
  sql = <<-EOQ
    select
      k.arn as key_arn
    from
      alicloud_kms_key k
      left join alicloud_ecs_disk as d on k.key_id = d.kms_key_id
    where
      d.arn = $1
      and k.arn is not null;
  EOQ
}

# table queries

query "ecs_disk_attached_instances" {
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

}

query "ecs_disk_encryption_status" {
  sql = <<-EOQ
    select
      case when encrypted then 'Enabled' else 'Disabled' end as "Encryption",
      kms_key_id as "KMS Key ID"
    from
      alicloud_ecs_disk
    where
      arn = $1;
  EOQ

}

query "ecs_disk_overview" {
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

}

query "ecs_disk_tags" {
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

}
