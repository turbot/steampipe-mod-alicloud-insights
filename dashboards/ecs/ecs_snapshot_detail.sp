dashboard "ecs_snapshot_detail" {

  title         = "AliCloud ECS Snapshot Detail"
  documentation = file("./dashboards/ecs/docs/ecs_snapshot_detail.md")

  tags = merge(local.ecs_common_tags, {
    type = "Detail"
  })

  input "snapshot_arn" {
    title = "Select a snapshot:"
    query = query.ecs_snapshot_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.ecs_snapshot_state
      args  = [self.input.snapshot_arn.value]
    }

    card {
      width = 2
      query = query.ecs_snapshot_usage_source_disk_size
      args  = [self.input.snapshot_arn.value]
    }

    card {
      width = 2
      query = query.ecs_snapshot_encryption
      args  = [self.input.snapshot_arn.value]
    }

    card {
      width = 2
      query = query.ecs_snapshot_age
      args  = [self.input.snapshot_arn.value]
    }

    card {
      width = 2
      query = query.ecs_snapshot_instant_access
      args  = [self.input.snapshot_arn.value]
    }

  }

  with "ecs_images_for_ecs_snapshot" {
    query = query.ecs_images_for_ecs_snapshot
    args  = [self.input.snapshot_arn.value]
  }

  with "ecs_instances_for_ecs_snapshot" {
    query = query.ecs_instances_for_ecs_snapshot
    args  = [self.input.snapshot_arn.value]
  }

  with "ecs_launch_templates_for_ecs_snapshot" {
    query = query.ecs_launch_templates_for_ecs_snapshot
    args  = [self.input.snapshot_arn.value]
  }

  with "source_ecs_disks_for_ecs_snapshot" {
    query = query.source_ecs_disks_for_ecs_snapshot
    args  = [self.input.snapshot_arn.value]
  }

  with "kms_keys_for_ecs_snapshot" {
    query = query.kms_keys_for_ecs_snapshot
    args  = [self.input.snapshot_arn.value]
  }

  with "target_ecs_disks_for_ecs_snapshot" {
    query = query.target_ecs_disks_for_ecs_snapshot
    args  = [self.input.snapshot_arn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ecs_disk
        args = {
          ecs_disk_arns = with.source_ecs_disks_for_ecs_snapshot.rows[*].disk_arn
        }
      }

      node {
        base = node.ecs_disk
        args = {
          ecs_disk_arns = with.target_ecs_disks_for_ecs_snapshot.rows[*].disk_arn
        }
      }

      node {
        base = node.ecs_image
        args = {
          ecs_image_arns = with.ecs_images_for_ecs_snapshot.rows[*].image_arn
        }
      }

      node {
        base = node.ecs_instance
        args = {
          ecs_instance_arns = with.ecs_instances_for_ecs_snapshot.rows[*].instance_arn
        }
      }

      node {
        base = node.ecs_launch_template
        args = {
          launch_template_ids = with.ecs_launch_templates_for_ecs_snapshot.rows[*].launch_template_id
        }
      }

      node {
        base = node.ecs_snapshot
        args = {
          ecs_snapshot_arns = [self.input.snapshot_arn.value]
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_arns = with.kms_keys_for_ecs_snapshot.rows[*].key_arn
        }
      }

      edge {
        base = edge.ecs_disk_to_ecs_snapshot
        args = {
          ecs_snapshot_arns = [self.input.snapshot_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_ecs_disk
        args = {
          ecs_instance_arns = with.ecs_instances_for_ecs_snapshot.rows[*].instance_arn
        }
      }

      edge {
        base = edge.ecs_launch_template_to_ecs_snapshot
        args = {
          launch_template_ids = with.ecs_launch_templates_for_ecs_snapshot.rows[*].launch_template_id
        }
      }

      edge {
        base = edge.ecs_snapshot_to_ecs_disk
        args = {
          ecs_snapshot_arns = [self.input.snapshot_arn.value]
        }
      }

      edge {
        base = edge.ecs_snapshot_to_ecs_image
        args = {
          ecs_snapshot_arns = [self.input.snapshot_arn.value]
        }
      }

      edge {
        base = edge.ecs_snapshot_to_kms_key
        args = {
          ecs_snapshot_arns = [self.input.snapshot_arn.value]
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
        query = query.ecs_snapshot_overview
        args  = [self.input.snapshot_arn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.ecs_snapshot_tags
        args  = [self.input.snapshot_arn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Source Disk"
        query = query.ecs_snapshot_source_disk
        args  = [self.input.snapshot_arn.value]

        column "Disk ARN" {
          display = "none"
        }

        column "Disk ID" {
          href = "${dashboard.ecs_disk_detail.url_path}?input.disk_arn={{.'Instance ARN' | @uri}}"
        }
      }

      table {
        title = "Encryption Details"
        column "KMS Key ID" {
          href = "${dashboard.kms_key_detail.url_path}?input.key_arn={{.'KMS Key ID' | @uri}}"
        }
        query = query.ecs_snapshot_encryption_status
        args  = [self.input.snapshot_arn.value]
      }
    }
  }

}

# Input queries

query "ecs_snapshot_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'snapshot_id', snapshot_id
      ) as tags
    from
      alicloud_ecs_snapshot
    order by
      title;
  EOQ
}

# with queries

query "ecs_images_for_ecs_snapshot" {
  sql = <<-EOQ
    select
      images.arn as image_arn
    from
      alicloud_ecs_image as images,
      jsonb_array_elements(images.disk_device_mappings) as ddm,
      alicloud_ecs_snapshot as s
    where
      ddm ->> 'SnapshotId' is not null
      and ddm ->> 'SnapshotId' = s.snapshot_id
      and s.arn = $1;
  EOQ
}

query "ecs_instances_for_ecs_snapshot" {
  sql = <<-EOQ
    select
      i.arn as instance_arn
    from
      alicloud_ecs_snapshot s
      join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
      join alicloud_ecs_instance as i on i.instance_id = d.instance_id
    where
      s.arn = $1;
  EOQ
}

query "ecs_launch_templates_for_ecs_snapshot" {
  sql = <<-EOQ
    select
      launch_template_id as launch_template_id
    from
      alicloud_ecs_snapshot as s,
      alicloud_ecs_launch_template,
      jsonb_array_elements(latest_version_details -> 'LaunchTemplateData' -> 'DataDisks' -> 'DataDisk') as disk_config
    where
      s.arn = $1
      and disk_config ->> 'SnapshotId' is not null
      and disk_config ->> 'SnapshotId' = s.snapshot_id;
  EOQ
}

query "source_ecs_disks_for_ecs_snapshot" {
  sql = <<-EOQ
    select
      d.arn as disk_arn
    from
      alicloud_ecs_snapshot s
      left join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
    where
      s.arn = $1
      and d.arn is not null;
  EOQ
}

query "target_ecs_disks_for_ecs_snapshot" {
  sql = <<-EOQ
    select
      d.arn as disk_arn
    from
      alicloud_ecs_snapshot s
      left join alicloud_ecs_disk as d on s.snapshot_id = d.source_snapshot_id
    where
      s.arn = $1
      and d.arn is not null;
  EOQ
}

query "kms_keys_for_ecs_snapshot" {
  sql = <<-EOQ
    select
      k.arn as key_arn
    from
      alicloud_kms_key k
      left join alicloud_ecs_snapshot as s on k.key_id = s.kms_key_id
    where
      s.arn = $1
      and k.arn is not null;
  EOQ
}

# card queries

query "ecs_snapshot_age" {
  sql = <<-EOQ
      with data as (
      select
        (EXTRACT(epoch FROM (SELECT (NOW() - creation_time)))/86400)::int as age
      from
        alicloud_ecs_snapshot
      where
        arn = $1
    )
    select
      'Age (in Days)' as label,
      age as value,
      case when age<35 then 'ok' else 'alert' end as type
    from
      data;
  EOQ
}

query "ecs_snapshot_usage_source_disk_size" {
  sql = <<-EOQ
    select
      'Source Disk Size (in Gib)' as label,
      source_disk_size as value
    from
      alicloud_ecs_snapshot
    where
      arn = $1;
  EOQ
}

query "ecs_snapshot_encryption" {
  sql = <<-EOQ
    select
      'Encrypted' as label,
      case when encrypted then 'Enabled' else 'Disabled' end as value,
      case when encrypted then 'ok' else 'alert' end as type
    from
      alicloud_ecs_snapshot
    where
      arn = $1;
  EOQ
}

query "ecs_snapshot_state" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      alicloud_ecs_snapshot
    where
      arn = $1;
  EOQ
}

query "ecs_snapshot_usage" {
  sql = <<-EOQ
    select
      'Usage' as label,
      usage as value
    from
      alicloud_ecs_snapshot
    where
      arn = $1;
  EOQ
}

query "ecs_snapshot_instant_access" {
  sql = <<-EOQ
    select
      'Instant Access' as label,
      case when instant_access then 'Enabled' else 'Disabled' end as value,
      case when instant_access then 'ok' else 'alert' end as type
    from
      alicloud_ecs_snapshot
    where
      arn = $1;
  EOQ
}

# Other detail page queries

query "ecs_snapshot_source_disk" {
  sql = <<-EOQ
    select
      d.disk_id as "Disk ID",
      d.name as "Name",
      d.arn as "Disk ARN",
      s.source_disk_size as "Disk Size",
      s.source_disk_type as "Disk Type",
      d.status as "Disk Status"
    from
      alicloud_ecs_snapshot as s
      join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
    where
      s.arn = $1
    order by
      s.source_disk_id;
  EOQ
}

query "ecs_snapshot_encryption_status" {
  sql = <<-EOQ
    select
      s.kms_key_id as "KMS Key ID",
      k.protection_level as "Protection Level",
      k.primary_key_version as "Key Version"
    from
      alicloud_ecs_snapshot as s,
      alicloud_kms_key as k
    where
      s.kms_key_id = k.key_id
      and s.arn = $1;
  EOQ
}

query "ecs_snapshot_overview" {
  sql = <<-EOQ
    select
      snapshot_id as "Snapshot ID",
      instant_access as "Instant Access",
      serial_number as "Serial No",
      type as "Type",
      last_modified_time as "Last Modified",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_ecs_snapshot
    where
      arn = $1
  EOQ
}

query "ecs_snapshot_tags" {
  sql = <<-EOQ
    select
      tag ->> 'TagKey' as "Key",
      tag ->> 'TagValue' as "Value"
    from
      alicloud_ecs_snapshot,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'Key';
  EOQ
}
