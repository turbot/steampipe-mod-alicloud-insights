dashboard "alicloud_oss_bucket_detail" {

  title         = "Alicloud OSS Bucket Detail"
  documentation = file("./dashboards/oss/docs/oss_bucket_detail.md")

  tags = merge(local.oss_common_tags, {
    type = "Detail"
  })

  input "bucket_arn" {
    title = "Select a bucket:"
    query = query.alicloud_oss_bucket_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.alicloud_oss_bucket_versioning
      args = {
        arn = self.input.bucket_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_oss_bucket_access_type
      args = {
        arn = self.input.bucket_arn.value
      }
    }

    card {
      query = query.alicloud_oss_bucket_logging_enabled
      width = 2
      args = {
        arn = self.input.bucket_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_oss_bucket_encryption
      args = {
        arn = self.input.bucket_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_oss_bucket_https_enforce
      args = {
        arn = self.input.bucket_arn.value
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
        query = query.alicloud_oss_bucket_overview
        args = {
          arn = self.input.bucket_arn.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.alicloud_oss_bucket_tags_detail
        param "arn" {}
        args = {
          arn = self.input.bucket_arn.value
        }
      }
    }

    container {
      width = 6

      table {
        title = "Logging"
        query = query.alicloud_oss_bucket_logging
        args = {
          arn = self.input.bucket_arn.value
        }
      }

    }

    container {
      width = 12
      table {
        title = "Policy"
        query = query.alicloud_oss_bucket_policy
        args = {
          arn = self.input.bucket_arn.value
        }
      }
    }

    container {
      width = 12
      table {
        title = "Lifecycle Rules"
        query = query.alicloud_oss_bucket_lifecycle_policy
        args = {
          arn = self.input.bucket_arn.value
        }
      }
    }

    container {
      width = 12
      table {
        title = "Server Side Encryption"
        query = query.alicloud_oss_bucket_server_side_encryption
        args = {
          arn = self.input.bucket_arn.value
        }
      }
    }

  }

}

query "alicloud_oss_bucket_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region
      ) as tags
    from
      alicloud_oss_bucket
    order by
      title;
  EOQ
}

query "alicloud_oss_bucket_versioning" {
  sql = <<-EOQ
    select
      'Versioning' as label,
      case when versioning <> '' then 'Enabled' else 'Disabled' end as value,
      case when versioning <> '' then 'ok' else 'alert' end as type
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_access_type" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when acl = 'private' then 'Disabled' else 'Enabled' end as value,
      case when acl = 'private' then 'ok' else 'alert' end as type
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_logging_enabled" {
  sql = <<-EOQ
    select
      'Logging' as label,
      case when (logging ->> 'TargetBucket') <> '' then 'Enabled' else 'Disabled' end as value,
      case when (logging ->> 'TargetBucket') <> '' then 'ok' else 'alert' end as type
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when server_side_encryption ->> 'SSEAlgorithm' <> '' then 'Enabled' else 'Disabled' end as value,
      case when server_side_encryption ->> 'SSEAlgorithm' <> '' then 'ok' else 'alert' end as type
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_https_enforce" {
  sql = <<-EOQ
    with ssl_ok as (
      select
        distinct name
      from
        alicloud_oss_bucket,
        jsonb_array_elements(policy -> 'Statement') as s,
        jsonb_array_elements_text(s -> 'Principal') as p,
        jsonb_array_elements_text(s -> 'Resource') as r,
        jsonb_array_elements_text(
          s -> 'Condition' -> 'Bool' -> 'acs:SecureTransport'
        ) as ssl
      where
        p = '*'
        and s ->> 'Effect' = 'Deny'
        and ssl :: bool = false
    )
    select
      'HTTPS' as label,
      case when s.name is not null then 'Enabled' else 'Disabled' end as value,
      case when s.name is not null then 'ok' else 'alert' end as type
    from
      alicloud_oss_bucket as b
      left join ssl_ok as s on s.name = b.name
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      creation_date as "Creation Date",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_tags_detail" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      alicloud_oss_bucket,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'Key';
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_logging" {
  sql = <<-EOQ
    select
      logging ->> 'TargetBucket' as "Target Bucket",
      logging ->> 'TargetPrefix' as "Target Prefix",
      logging -> 'XMLName' ->> 'Local' as "Local",
      logging -> 'XMLName' ->> 'Space' as "Space"
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_policy" {
  sql = <<-EOQ
    select
      p -> 'Principal' as "Principal",
      p -> 'Action' as "Action",
      p ->> 'Effect' as "Effect",
      p -> 'Resource' as "Resource",
      policy ->> 'Version' as "Version"
    from
      alicloud_oss_bucket,
      jsonb_array_elements(policy -> 'Statement') as p
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_lifecycle_policy" {
  sql = <<-EOQ
    select
      r ->> 'ID' as "ID",
      r ->> 'AbortMultipartUpload' as "Abort Multipart Upload",
      r ->> 'Expiration' as "Expiration",
      r ->> 'NonVersionExpiration' as "Non Version Expiration",
      r ->> 'NonVersionTransition' as "Non Version Transition",
      r ->> 'Prefix' as "Prefix",
      r ->> 'NonVersionTransitions' as "Non Version Transitions",
      r ->> 'Status' as "Status",
      r ->> 'Tags' as "Tags",
      r ->> 'Transitions' as "Transitions",
      r ->>  'XMLName' as "XML Name"
    from
      alicloud_oss_bucket,
      jsonb_array_elements(lifecycle_rules) as r
    where
      arn = $1
    order by
      r ->> 'ID';
  EOQ

  param "arn" {}
}

query "alicloud_oss_bucket_server_side_encryption" {
  sql = <<-EOQ
    select
      server_side_encryption ->> 'KMSMasterKeyID' as "KMS Master Key ID",
      server_side_encryption ->> 'SSEAlgorithm' as "SSE Algorithm",
      server_side_encryption ->> 'KMSDataEncryption' as "KMS Data Encryption"
    from
      alicloud_oss_bucket
    where
      arn = $1;
  EOQ

  param "arn" {}
}
