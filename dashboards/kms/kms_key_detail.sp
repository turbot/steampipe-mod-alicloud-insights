dashboard "kms_key_detail" {

  title         = "AliCloud Key Detail"
  documentation = file("./dashboards/kms/docs/kms_key_detail.md")

  tags = merge(local.kms_common_tags, {
    type = "Detail"
  })


  input "key_arn" {
    title = "Select a key:"
    query = query.kms_key_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kms_key_origin
      args  = [self.input.key_arn.value]
    }

    card {
      width = 2
      query = query.kms_key_state
      args  = [self.input.key_arn.value]
    }

    card {
      width = 2
      query = query.kms_key_rotation_enabled
      args  = [self.input.key_arn.value]
    }

    card {
      width = 2
      query = query.kms_deletion_protection
      args  = [self.input.key_arn.value]
    }

    card {
      width = 2
      query = query.kms_protection_level
      args  = [self.input.key_arn.value]
    }

  }

  with "ecs_disks" {
    query = query.kms_key_ecs_disks
    args = [self.input.key_arn.value]
  }

  with "ecs_snapshots" {
    query = query.kms_key_ecs_snapshots
    args = [self.input.key_arn.value]
  }

  with "kms_secrets" {
    query = query.kms_key_kms_secrets
    args = [self.input.key_arn.value]
  }

  with "oss_buckets" {
    query = query.kms_key_oss_buckets
    args = [self.input.key_arn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ecs_disk
        args = {
          ecs_disk_arns = with.ecs_disks.rows[*].disk_arn
        }
      }

      node {
        base = node.ecs_snapshot
        args = {
          ecs_snapshot_arns = with.ecs_snapshots.rows[*].snapshot_arn
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_arns = [self.input.key_arn.value]
        }
      }

      node {
        base = node.kms_secret
        args = {
          kms_secret_arns = with.kms_secrets.rows[*].secret_arn
        }
      }

      node {
        base = node.oss_bucket
        args = {
          oss_bucket_arns = with.oss_buckets.rows[*].bucket_arn
        }
      }

      edge {
        base = edge.ecs_disk_to_kms_key
        args = {
          ecs_disk_arns = with.ecs_disks.rows[*].disk_arn
        }
      }

      edge {
        base = edge.ecs_snapshot_to_kms_key
        args = {
          ecs_snapshot_arns = with.ecs_snapshots.rows[*].snapshot_arn
        }
      }

      edge {
        base = edge.kms_secret_to_kms_key
        args = {
          kms_secret_arns = with.kms_secrets.rows[*].secret_arn
        }
      }

      edge {
        base = edge.oss_bucket_to_kms_key
        args = {
          oss_bucket_arns = with.oss_buckets.rows[*].bucket_arn
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
        query = query.kms_key_overview
        args  = [self.input.key_arn.value]

      }

      table {
        title = "Tags"
        width = 6
        query = query.kms_key_tags
        args  = [self.input.key_arn.value]
      }

    }

    container {

      width = 6

      table {
        title = "Key Age"
        query = query.kms_key_age
        args  = [self.input.key_arn.value]
      }

    }

  }

  table {
    title = "Key Aliases"
    query = query.kms_key_aliases
    args  = [self.input.key_arn.value]
  }

}

# input queries

query "kms_key_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region
      ) as tags
    from
      alicloud_kms_key
    order by
      title;
  EOQ
}

# with queries

query "kms_key_kms_secrets" {
    sql = <<-EOQ
    select
      s.arn as secret_arn
    from
      alicloud_kms_secret as s
      left join alicloud_kms_key k on s.encryption_key_id = k.key_id
    where
      k.arn = $1
      and s.arn is not null;
  EOQ
}

query "kms_key_oss_buckets" {
    sql = <<-EOQ
    select
      b.arn as bucket_arn
    from
      alicloud_oss_bucket as b
      left join alicloud_kms_key k on b.server_side_encryption ->> 'KMSMasterKeyID' = k.key_id
    where
      k.arn = $1
      and b.arn is not null;
  EOQ
}

query "kms_key_ecs_disks" {
  sql = <<-EOQ
    select
      d.arn as disk_arn
    from
      alicloud_ecs_disk as d
      left join alicloud_kms_key k on d.kms_key_id = k.key_id
    where
      k.arn = $1
      and d.arn is not null;
  EOQ
}

query "kms_key_ecs_snapshots" {
  sql = <<-EOQ
    select
      s.arn as snapshot_arn
    from
      alicloud_ecs_snapshot as s
      left join alicloud_kms_key k on s.kms_key_id = k.key_id
    where
      k.arn = $1
      and s.arn is not null;
  EOQ
}

query "kms_key_rds_instances" {
  sql = <<-EOQ
    select
      s.arn as snapshot_arn
    from
      alicloud_ecs_snapshot as s
      left join alicloud_kms_key k on s.kms_key_id = k.key_id
    where
      k.arn = $1
      and s.arn is not null;
  EOQ
}

# card queries

query "kms_key_origin" {
  sql = <<-EOQ
    select
      'Origin' as label,
      origin as value
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ
}

query "kms_key_state" {
  sql = <<-EOQ
    select
      'State' as label,
      key_state as value
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ
}

query "kms_key_rotation_enabled" {
  sql = <<-EOQ
    select
      'Key Rotation' as label,
      automatic_rotation as value,
      case when automatic_rotation='Enabled' then 'ok' else 'alert' end as type
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ
}

query "kms_deletion_protection" {
  sql = <<-EOQ
    select
      'Deletion Protection' as label,
      deletion_protection as value,
      case when deletion_protection='Enabled' then 'ok' else 'alert' end as type
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ
}

query "kms_protection_level" {
  sql = <<-EOQ
    select
      'Protection Level' as label,
      initcap(protection_level) as value,
      case when protection_level='SOFTWARE' then 'ok' else 'alert' end as type
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ
}

# Other detail page queries

query "kms_key_overview" {
  sql = <<-EOQ
    select
      key_id as "ID",
      title as "Title",
      primary_key_version as "Primary Key Version",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_kms_key
    where
      arn = $1
    EOQ
}

query "kms_key_tags" {
  sql = <<-EOQ
    select
      tag ->> 'TagKey' as "Key",
      tag ->> 'TagValue' as "Value"
    from
      alicloud_kms_key,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'TagKey';
    EOQ
}

query "kms_key_age" {
  sql = <<-EOQ
    select
      creation_date as "Creation Date",
      delete_date as "Deletion Date",
      extract(day from delete_date - current_date)::int as "Deleting After Days"
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ
}

query "kms_key_aliases" {
  sql = <<-EOQ
    select
      p ->> 'AliasArn' as "Alias Arn",
      p ->> 'AliasName' as "Alias Name",
      p ->> 'KeyId' as "Key ID"
    from
      alicloud_kms_key,
      jsonb_array_elements(key_aliases) as p
    where
      arn = $1;
  EOQ
}
