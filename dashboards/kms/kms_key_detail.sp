dashboard "alicloud_kms_key_detail" {

  title         = "Alibaba Cloud Key Detail"
  documentation = file("./dashboards/kms/docs/kms_key_detail.md")

  tags = merge(local.kms_common_tags, {
    type = "Detail"
  })


  input "key_arn" {
    title = "Select a key:"
    sql   = query.alicloud_kms_key_input.sql
    width = 4
  }

  container {

    card {
      width = 2
      query = query.alicloud_kms_key_origin
      args  = {
        arn = self.input.key_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_kms_key_state
      args  = {
        arn = self.input.key_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_kms_key_rotation_enabled
      args  = {
        arn = self.input.key_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_kms_deletion_protection
      args  = {
        arn = self.input.key_arn.value
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
        query = query.alicloud_kms_key_overview
        args  = {
          arn = self.input.key_arn.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.alicloud_kms_key_tags
        args  = {
          arn = self.input.key_arn.value
        }
      }

    }

    container {

      width = 6

      table {
        title = "Key Age"
        query = query.alicloud_kms_key_age
        args  = {
          arn = self.input.key_arn.value
        }
      }

    }

  }

  table {
    title = "Key Aliases"
    query = query.alicloud_kms_key_aliases
    args  = {
      arn = self.input.key_arn.value
    }
  }

}

query "alicloud_kms_key_input" {
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

query "alicloud_kms_key_origin" {
  sql = <<-EOQ
    select
      'Origin' as label,
      origin as value
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_kms_key_state" {
  sql = <<-EOQ
    select
      'State' as label,
      key_state as value,
      case when key_state = 'Enabled' then 'ok' else 'alert' end as "type"
    from
      alicloud_kms_key
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_kms_key_rotation_enabled" {
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

  param "arn" {}
}

query "alicloud_kms_deletion_protection" {
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

  param "arn" {}
}

query "alicloud_kms_key_age" {
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

  param "arn" {}
}

query "alicloud_kms_key_aliases" {
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

  param "arn" {}
}

query "alicloud_kms_key_overview" {
  sql = <<-EOQ
    select
      key_id as "ID",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_kms_key
    where
      arn = $1
    EOQ

  param "arn" {}
}

query "alicloud_kms_key_tags" {
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

  param "arn" {}
}