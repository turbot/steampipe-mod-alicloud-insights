dashboard "alicloud_rds_instance_detail" {

  title         = "AliCloud RDS Instance Detail"
  documentation = file("./dashboards/rds/docs/rds_instance_detail.md")

  tags = merge(local.rds_common_tags, {
    type = "Detail"
  })

  input "instance_arn" {
    title = "Select a DB Instance:"
    query = query.alicloud_rds_instance_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.alicloud_rds_instance_engine_type
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_rds_instance_class
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_rds_instance_public
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_rds_instance_ssl_status
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.alicloud_rds_instance_tde_status
      args = {
        arn = self.input.instance_arn.value
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
        query = query.alicloud_rds_instance_overview
        args = {
          arn = self.input.instance_arn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.alicloud_rds_instance_tags
        args = {
          arn = self.input.instance_arn.value
        }
      }


    }

    container {

      width = 6

    #   table {
    #     title = "DB Parameter Groups"
    #     query = query.alicloud_rds_instance_parameter_groups
    #     args = {
    #       arn = self.input.instance_arn.value
    #     }
    #   }

      table {
        title = "Subnets"
        query = query.alicloud_rds_instance_subnets
        args = {
          arn = self.input.instance_arn.value
        }
      }

    }

    container {

      width = 12

      table {
        width = 6
        title = "Storage"
        query = query.alicloud_rds_instance_storage
        args = {
          arn = self.input.instance_arn.value
        }
      }

      table {
        width = 6
        title = "Auditing"
        query = query.alicloud_rds_instance_auditing
        args = {
          arn = self.input.instance_arn.value
        }
      }

    }

    container {

      width = 12

      table {
        width = 6
        title = "Security Groups"
        query = query.alicloud_rds_instance_security_groups
        args = {
          arn = self.input.instance_arn.value
        }
      }

      table {
        width = 6
        title = "DB Subnet Groups"
        query = query.alicloud_rds_instance_db_subnet_groups
        args = {
          arn = self.input.instance_arn.value
        }
      }

    }

  }

}

query "alicloud_rds_instance_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region
      ) as tags
    from
      alicloud_rds_instance
    order by
      title;
  EOQ
}

query "alicloud_rds_instance_engine_type" {
  sql = <<-EOQ
    select
      'Engine Type' as label,
      engine as value
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_class" {
  sql = <<-EOQ
    select
      'Class' as label,
      db_instance_class as value
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_public" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when not security_ips :: jsonb ? '0.0.0.0/0' then 'Disabled' else 'Enabled' end as value,
      case when not  security_ips :: jsonb ? '0.0.0.0/0' then 'ok' else 'alert' end as type
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_ssl_status" {
  sql = <<-EOQ
    select
      'SSL Status' as label,
      ssl_status as value,
      case when ssl_status='Enabled' then 'ok' else 'alert' end as type
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_tde_status" {
  sql = <<-EOQ
    select
      'TDE Status' as label,
      tde_status as value,
      case when tde_status='Enabled' then 'ok' else 'alert' end as type
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

# query "alicloud_rds_instance_parameter_groups" {
#   sql = <<-EOQ
#     select
#       p ->> 'DBParameterGroupName' as "DB Parameter Group Name",
#       p ->> 'ParameterApplyStatus' as "Parameter Apply Status"
#     from
#       alicloud_rds_instance,
#       jsonb_array_elements(parameters) as p
#     where
#       arn = $1;
#   EOQ

#   param "arn" {}
# }

query "alicloud_rds_instance_subnets" {
  sql = <<-EOQ
    select
      p ->> 'SubnetIdentifier' as "Subnet Identifier",
      p -> 'SubnetAvailabilityZone' ->> 'Name' as "Subnet Availability Zone",
      p ->> 'SubnetStatus'  as "Subnet Status"
    from
      alicloud_rds_instance,
      jsonb_array_elements(subnets) as p
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_storage" {
  sql = <<-EOQ
    select
      db_instance_storage_type as "Storage Type",
      db_instance_storage as "Allocated Storage(GB)"
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_auditing" {
  sql = <<-EOQ
    select
      sql_collector_policy ->> 'SQLCollectorStatus' as "SQL Collector Status",
      sql_collector_retention as "SQL Collector Retention(days)"
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_security_groups" {
  sql = <<-EOQ
    select
      s ->> 'VpcSecurityGroupId' as "VPC Security Group ID",
      s ->> 'Status' as "Status"
    from
      alicloud_rds_instance,
      jsonb_array_elements(vpc_security_groups) as s
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_db_subnet_groups" {
  sql = <<-EOQ
    select
      db_subnet_group_name as "DB Subnet Group Name",
      db_subnet_group_arn as "DB Subnet Group ARN",
      db_subnet_group_status as "DB Subnet Group Status"
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_overview" {
  sql = <<-EOQ
    select
      db_instance_id as "DB Instance Id",
      case
        when vpc_id is not null and vpc_id != '' then vpc_id
        else 'N/A'
      end as "VPC ID",
      creation_time as "Create Time",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "alicloud_rds_instance_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      alicloud_rds_instance,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'Key';
    EOQ

  param "arn" {}
}
