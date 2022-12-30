dashboard "rds_instance_detail" {

  title         = "Alicloud RDS Instance Detail"
  documentation = file("./dashboards/rds/docs/rds_instance_detail.md")

  tags = merge(local.rds_common_tags, {
    type = "Detail"
  })

  input "db_instance_arn" {
    title = "Select a DB Instance:"
    query = query.rds_instance_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.rds_instance_engine_type
      args  = [self.input.db_instance_arn.value]
    }

    card {
      width = 2
      query = query.rds_instance_class
      args  = [self.input.db_instance_arn.value]
    }

    card {
      width = 2
      query = query.rds_instance_storage
      args  = [self.input.db_instance_arn.value]
    }

    card {
      width = 2
      query = query.rds_instance_instance_public_access
      args  = [self.input.db_instance_arn.value]
    }

    card {
      width = 2
      query = query.rds_instance_instance_tde_status
      args  = [self.input.db_instance_arn.value]
    }

    card {
      width = 2
      query = query.rds_instance_ssl_enabled
      args  = [self.input.db_instance_arn.value]
    }

  }

  with "ecs_security_groups" {
    query = query.rds_instance_ecs_security_groups
    args  = [self.input.db_instance_arn.value]
  }

  with "rds_read_only_db_instances" {
    query = query.rds_instance_rds_read_only_db_instances
    args = [self.input.db_instance_arn.value]
  }

  with "rds_databases"{
    query = query.rds_instance_rds_database_names
    args = [self.input.db_instance_arn.value]
  }

  with "rds_backups"{
    query = query.rds_instance_rds_backup_ids
    args = [self.input.db_instance_arn.value]
  }

  with "ecs_autoscaling_groups" {
    query = query.rds_instance_ecs_autoscaling_groups
    args = [self.input.db_instance_arn.value]
  }

  with "vpc_vswitches" {
    query = query.rds_instance_vpc_vswitches
    args  = [self.input.db_instance_arn.value]
  }

  with "vpc_vpcs" {
    query = query.rds_instance_vpc_vpcs
    args  = [self.input.db_instance_arn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "top-down"

      node {
        base = node.rds_database
        args = {
          rds_database_names = with.rds_databases.rows[*].database_name
        }
      }

      node {
        base = node.rds_backup
        args = {
          rds_database_backup_ids = with.rds_backups.rows[*].backup_id
        }
      }

      node {
        base = node.rds_instance
        args = {
          rds_db_instance_arns = [self.input.db_instance_arn.value]
        }
      }

      node {
        base = node.ecs_autoscaling_group
        args = {
          ecs_autoscaling_group_ids = with.ecs_autoscaling_groups.rows[*].autoscaling_group_id
        }
      }

      node {
        base = node.rds_instance
        args = {
          rds_db_instance_arns = with.rds_read_only_db_instances.rows[*].db_instance_arn
        }
      }

      node {
        base = node.rds_instance
        args = {
          rds_db_instance_arns = with.rds_read_only_db_instances.rows[*].db_instance_arn
        }
      }

      node {
        base = node.ecs_security_group
        args = {
          ecs_security_group_ids = with.ecs_security_groups.rows[*].security_group_id
        }
      }

      node {
        base = node.vpc_vswitch
        args = {
          vpc_vswitch_ids = with.vpc_vswitches.rows[*].vpc_vswitch_id
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = with.vpc_vpcs.rows[*].vpc_id
        }
      }

      edge {
        base = edge.ecs_autoscaling_group_to_rds_instance
        args = {
          ecs_autoscaling_group_ids = with.ecs_autoscaling_groups.rows[*].autoscaling_group_id
        }
      }

      edge {
        base = edge.rds_db_instance_to_ecs_security_group
        args = {
          rds_db_instance_arns = [self.input.db_instance_arn.value]
        }
      }

      edge {
        base = edge.rds_instance_to_vpc_vswitch
        args = {
          rds_db_instance_arns = [self.input.db_instance_arn.value]
        }
      }

      edge {
        base = edge.rds_db_instance_to_read_only_db_instances
        args = {
          rds_db_instance_arns = [self.input.db_instance_arn.value]
        }
      }

      edge {
        base = edge.rds_db_instance_to_read_only_db_instances
        args = {
          rds_db_instance_arns = with.rds_read_only_db_instances.rows[*].db_instance_arn
        }
      }

      edge {
        base = edge.rds_db_instance_to_rds_database
        args = {
          rds_db_instance_arns = [self.input.db_instance_arn.value]
        }
      }

      edge {
        base = edge.rds_db_instance_to_rds_backup
        args = {
          rds_db_instance_arns = [self.input.db_instance_arn.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_vpc_vpc
        args = {
          vpc_vswitch_ids = with.vpc_vswitches.rows[*].vpc_vswitch_id
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
        query = query.rds_instance_overview
        args  = [self.input.db_instance_arn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.rds_instance_tags
        args  = [self.input.db_instance_arn.value]
      }

    }

    container {

      width = 6

      table {
        title = "DB Parameter Groups"
        query = query.rds_instance_parameter_groups
        args  = [self.input.db_instance_arn.value]
      }
    }

    container {

      width = 12

      table {
        title = "Security IPs"
        query = query.rds_instance_security_ips
        args  = [self.input.db_instance_arn.value]
      }
    }

  }

}

# Input queries

query "rds_instance_input" {
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

# With queries

query "rds_instance_vpc_vswitches" {
  sql = <<-EOQ
    select
      vswitch_id as vpc_vswitch_id
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_ecs_autoscaling_groups" {
  sql = <<-EOQ
    select
      asg.scaling_group_id as autoscaling_group_id
    from
      alicloud_rds_instance as rdi,
      alicloud_ecs_autoscaling_group as asg,
      jsonb_array_elements_text(asg.db_instance_ids) as id
    where
      rdi.arn = $1
      and rdi.db_instance_id = id;
  EOQ
}

query "rds_instance_vpc_vpcs" {
  sql = <<-EOQ
    select
      vpc_id
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_rds_read_only_db_instances" {
  sql = <<-EOQ
    select
      related_instances.arn as db_instance_arn
    from
      alicloud_rds_instance as self,
      alicloud_rds_instance as related_instances
    where
      self.arn = $1
      and (related_instances.master_instance_id = self.db_instance_id or self.master_instance_id = related_instances.db_instance_id)
  EOQ
}

query "rds_instance_rds_database_names" {
  sql = <<-EOQ
    select
      d.db_name as database_name
    from
      alicloud_rds_instance as i,
      alicloud_rds_database as d
    where
      i.arn = $1
      and d.db_instance_id = i.db_instance_id;
  EOQ
}

query "rds_instance_rds_backup_ids" {
  sql = <<-EOQ
    select
      b.backup_id as backup_id
    from
      alicloud_rds_instance as i,
      alicloud_rds_backup as b
    where
      i.arn = $1
      and b.db_instance_id = i.db_instance_id;
  EOQ
}

query "rds_instance_ecs_security_groups" {
  sql = <<-EOQ
    select
      isg->>'SecurityGroupId' as security_group_id
    from
      alicloud_rds_instance as i,
      jsonb_array_elements(i.security_group_configuration) as isg,
      alicloud_ecs_security_group as sg
    where
      i.arn = $1
      and isg->>'SecurityGroupId' = sg.security_group_id;
  EOQ
}

# Card queries

query "rds_instance_engine_type" {
  sql = <<-EOQ
    select
      'Engine Type' as label,
      engine as value
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_class" {
  sql = <<-EOQ
    select
      'Class' as label,
      db_instance_class as value
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_storage" {
  sql = <<-EOQ
    select
      'Storage (in GB)' as label,
      db_instance_storage as value
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_instance_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when db_instance_net_type = 'Extranet' then 'Enabled' else 'Disabled' end as value,
      case when db_instance_net_type = 'Extranet' then 'alert' else 'ok' end as type
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_instance_tde_status" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when tde_status = 'Enabled' then 'Enabled' else 'Disabled' end as value,
      case when tde_status = 'Enabled' then 'ok' else 'alert' end as type
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_ssl_enabled" {
  sql = <<-EOQ
    select
      'SSL' as label,
      case when ssl_status = 'Enabled' then 'Enabled' else 'Disabled' end as value,
      case when ssl_status = 'Enabled' then 'ok' else 'alert' end as type
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

# Other detail page queries

query "rds_instance_parameter_groups" {
  sql = <<-EOQ
    select
      p ->> 'ParameterName' as "DB Parameter Group Name",
      p ->> 'ParameterValue' as "Parameter Value"
    from
      alicloud_rds_instance,
      jsonb_array_elements(parameters -> 'RunningParameters' -> 'DBInstanceParameter') as p
    where
      arn = $1;
  EOQ
}

query "rds_instance_security_ips" {
  sql = <<-EOQ
    select
      s ->> 'DBInstanceIPArrayName' as "Instance IP Name",
      s ->> 'SecurityIPType' as "Security IP Type",
      s ->> 'WhitelistNetworkType' as "White List Network Type",
      security_ip_mode as "Security Group IP Mode"
    from
      alicloud_rds_instance,
      jsonb_array_elements(security_ips_src) as s
    where
      arn = $1;
  EOQ
}

query "rds_instance_overview" {
  sql = <<-EOQ
    select
      db_instance_id as "DB Instance ID",
      case
        when vpc_id is not null and vpc_id != '' then vpc_id
        else 'N/A'
      end as "VPC ID",
      creation_time as "Create Time",
      pay_type as "Pay Type",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      instance_network_type as "Instance Network Type",
      arn as "ARN"
    from
      alicloud_rds_instance
    where
      arn = $1;
  EOQ
}

query "rds_instance_tags" {
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
}
