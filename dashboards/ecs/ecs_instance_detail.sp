dashboard "ecs_instance_detail" {

  title         = "AliCloud ECS Instance Detail"
  documentation = file("./dashboards/ecs/docs/ecs_instance_detail.md")

  tags = merge(local.ecs_common_tags, {
    type = "Detail"
  })

  input "instance_arn" {
    title = "Select an instance:"
    query = query.ecs_instance_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.ecs_instance_status
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = query.ecs_instance_type
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = query.ecs_instance_total_cores
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = query.ecs_instance_os_type
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = query.ecs_instance_public_access
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = query.ecs_instance_io_optimized
      args  = [self.input.instance_arn.value]
    }

  }

  with "ecs_disks_for_ecs_instance" {
    query = query.ecs_disks_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "ecs_images_for_ecs_instance" {
    query = query.ecs_images_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "ecs_autoscaling_groups_for_ecs_instance" {
    query = query.ecs_autoscaling_groups_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "ecs_network_interfaces_for_ecs_instance" {
    query = query.ecs_network_interfaces_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "ecs_snapshots_for_ecs_instance" {
    query = query.ecs_snapshots_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "ecs_security_groups_for_ecs_instance" {
    query = query.ecs_security_groups_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_eips_for_ecs_instance" {
    query = query.vpc_eips_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_vswitches_for_ecs_instance" {
    query = query.vpc_vswitches_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_vpcs_for_ecs_instance" {
    query = query.vpc_vpcs_for_ecs_instance
    args  = [self.input.instance_arn.value]
  }

  container {

    graph {

      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.cms_monitor_host
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ecs_auto_provisioning_group
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ecs_autoscaling_group
        args = {
          ecs_autoscaling_group_ids = with.ecs_autoscaling_groups_for_ecs_instance.rows[*].autoscaling_group_id
        }
      }

      node {
        base = node.ecs_disk
        args = {
          ecs_disk_arns = with.ecs_disks_for_ecs_instance.rows[*].disk_arn
        }
      }

      node {
        base = node.ecs_image
        args = {
          ecs_image_ids = with.ecs_images_for_ecs_instance.rows[*].image_id
        }
      }

      node {
        base = node.ecs_instance
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ecs_key_pair
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ecs_network_interface
        args = {
          ecs_network_interface_ids = with.ecs_network_interfaces_for_ecs_instance.rows[*].network_interface_id
        }
      }

      node {
        base = node.ecs_security_group
        args = {
          ecs_security_group_ids = with.ecs_security_groups_for_ecs_instance.rows[*].security_group_id
        }
      }

      node {
        base = node.ecs_snapshot
        args = {
          ecs_snapshot_arns = with.ecs_snapshots_for_ecs_instance.rows[*].snapshot_arn
        }
      }

      node {
        base = node.vpc_eip
        args = {
          vpc_eip_arns = with.vpc_eips_for_ecs_instance.rows[*].eip_arn
        }
      }

      node {
        base = node.vpc_vswitch
        args = {
          vpc_vswitch_ids = with.vpc_vswitches_for_ecs_instance.rows[*].vpc_vswitch_id
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = with.vpc_vpcs_for_ecs_instance.rows[*].vpc_id
        }
      }

      edge {
        base = edge.cms_monitor_host_to_ecs_instance
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_auto_provisioning_group_to_ecs_instance
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_autoscaling_group_to_ecs_instance
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_disk_to_ecs_snapshot
        args = {
          ecs_snapshot_arns = with.ecs_snapshots_for_ecs_instance.rows[*].snapshot_arn
        }
      }

      edge {
        base = edge.ecs_image_to_ecs_instance
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_ecs_disk
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_ecs_key_pair
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_ecs_network_interface
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_ecs_security_group
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_instance_to_vpc_vswitch
        args = {
          ecs_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ecs_network_interface_to_vpc_eip
        args = {
          ecs_network_interface_ids = with.ecs_network_interfaces_for_ecs_instance.rows[*].network_interface_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_vpc_vpc
        args = {
          vpc_vswitch_ids = with.vpc_vswitches_for_ecs_instance.rows[*].vpc_vswitch_id
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
        query = query.ecs_instance_overview
        args  = [self.input.instance_arn.value]

      }

      table {
        title = "Tags"
        width = 6
        query = query.ecs_instance_tags
        args  = [self.input.instance_arn.value]
      }
    }
    container {
      width = 6

      table {
        title = " CPU cores"
        query = query.ecs_instance_cpu_cores
        args  = [self.input.instance_arn.value]
      }
    }

  }

  container {
    width = 12

    table {
      title = "Network Interfaces"
      query = query.ecs_instance_network_interfaces
      args  = [self.input.instance_arn.value]
    }

  }

  container {
    width = 6

    table {
      title = "Dedicated Host"
      query = query.ecs_instance_dedicated_host
      args  = [self.input.instance_arn.value]
    }

  }

  container {
    width = 6

    table {
      title = "Security Groups"
      query = query.ecs_instance_security_groups
      args  = [self.input.instance_arn.value]
    }

  }

  container {
    width = 6

    table {
      title = "VPC Details"
      query = query.ecs_instance_vpc
      args  = [self.input.instance_arn.value]
    }

  }

}

# Inpur queries

query "ecs_instance_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'instance_id', instance_id
      ) as tags
    from
      alicloud_ecs_instance
    order by
      title;
  EOQ
}

# with queries

query "ecs_disks_for_ecs_instance" {
  sql = <<-EOQ
    select
      d.arn as disk_arn
    from
      alicloud_ecs_instance i
      left join alicloud_ecs_disk as d on i.instance_id = d.instance_id
    where
      i.arn = $1;
  EOQ
}

query "ecs_images_for_ecs_instance" {
  sql = <<-EOQ
    select
      image_id as image_id
    from
      alicloud_ecs_instance
    where
      arn = $1
      and image_id is not null;
  EOQ
}

query "ecs_autoscaling_groups_for_ecs_instance" {
  sql = <<-EOQ
    select
      asg.scaling_group_id as autoscaling_group_id
    from
      alicloud_ecs_autoscaling_group as asg,
      jsonb_array_elements(asg.scaling_instances) as group_instance,
      alicloud_ecs_instance as i
    where
      i.arn = $1
      and group_instance ->> 'InstanceId' = i.instance_id;
  EOQ
}

query "ecs_network_interfaces_for_ecs_instance" {
  sql = <<-EOQ
    select
      p ->> 'NetworkInterfaceId' as network_interface_id
    from
      alicloud_ecs_instance,
      jsonb_array_elements(network_interfaces) as p
    where
      arn = $1
      and  p ->> 'NetworkInterfaceId' is not null;
  EOQ
}

query "ecs_snapshots_for_ecs_instance" {
  sql = <<-EOQ
    select
      s.arn as snapshot_arn
    from
      alicloud_ecs_snapshot s
      join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
      join alicloud_ecs_instance as i on i.instance_id = d.instance_id
    where
      i.arn = $1;
  EOQ
}

query "vpc_vswitches_for_ecs_instance" {
  sql = <<-EOQ
    select
      vpc_attributes ->> 'VSwitchId' as vpc_vswitch_id
    from
      alicloud_ecs_instance i
    where
      i.arn = $1;
  EOQ
}

query "ecs_security_groups_for_ecs_instance" {
  sql = <<-EOQ
    select
      group_id  as security_group_id
    from
      alicloud_ecs_instance as i,
      jsonb_array_elements_text(security_group_ids) as group_id
    where
      i.arn = $1;
  EOQ
}

query "vpc_eips_for_ecs_instance" {
  sql = <<-EOQ
    select
      e.arn as eip_arn
    from
      alicloud_ecs_instance i
      left join alicloud_vpc_eip as e on i.instance_id = e.instance_id
    where
      i.arn = $1
      and e.arn is not null;
  EOQ
}

query "vpc_vpcs_for_ecs_instance" {
  sql = <<-EOQ
    select
      vpc_attributes ->> 'VpcId' as vpc_id
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

# Card queries

query "ecs_instance_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      status as value
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_os_type" {
  sql = <<-EOQ
    select
      'OS Type' as label,
      os_type as value
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      instance_type as value
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_total_cores" {
  sql = <<-EOQ
    select
      'Total Cores' as label,
      sum(cpu_options_core_count) as value
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when public_ip_address is null then 'Disabled' else 'Enabled' end as value,
      case when public_ip_address is null then 'ok' else 'alert' end as type
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_io_optimized" {
  sql = <<-EOQ
    select
      'I/O Optimized' as label,
      case when io_optimized then 'Enabled' else 'Disabled' end as value,
      case when io_optimized then 'ok' else 'alert' end as type
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

# Other detail page queries

query "ecs_instance_overview" {
  sql = <<-EOQ
    select
      tags ->> 'Name' as "Name",
      instance_id as "Instance ID",
      os_name_en as "OS Name",
      network_type as "Network Type",
      creation_time as "Creation Time",
      billing_method as "Billing Method",
      internet_charge_type as "Internet Charge Type",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_tags" {
  sql = <<-EOQ
    select
      tag ->> 'TagKey' as "Key",
      tag ->> 'TagValue' as "Value"
    from
      alicloud_ecs_instance,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'TagKey';
    EOQ
}

query "ecs_instance_cpu_cores" {
  sql = <<-EOQ
    select
      cpu_options_core_count  as "CPU Options Core Count",
      cpu_options_threads_per_core  as "CPU Options Threads Per Core"
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_network_interfaces" {
  sql = <<-EOQ
    select
      p ->> 'NetworkInterfaceId' as "Network Interface ID",
      p ->> 'Type' as "Interface Type",
      p ->> 'PrimaryIpAddress' as "Primary Ip Address",
      private_ip_address as "Private IP Address",
      public_ip_address as "Public IP Address",
      public_ip_address as "Public IP Address",
      vpc_id as "VPC ID"
    from
      alicloud_ecs_instance,
      jsonb_array_elements(network_interfaces) as p
    where
      arn = $1;
  EOQ
}

query "ecs_instance_dedicated_host" {
  sql = <<-EOQ
    select
      dedicated_host_name as "Name",
      dedicated_host_id  as "ID",
      dedicated_host_cluster_id  as "Cluster ID",
      dedicated_instance_affinity as "Instance Affinity",
      dedicated_instance_tenancy  as "Instance Tenancy"
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}

query "ecs_instance_security_groups" {
  sql = <<-EOQ
    select
      group_id  as "Group ID",
      g.name
    from
      alicloud_ecs_instance as i,
      jsonb_array_elements_text(security_group_ids) as group_id
      left join alicloud_ecs_security_group as g on g.security_group_id = group_id
    where
      i.arn = $1;
  EOQ
}

query "ecs_instance_vpc" {
  sql = <<-EOQ
    select
      vpc_attributes ->> 'VpcId' as "ID",
      vpc_attributes ->> 'NatIpAddress'  as "Nat IP Address",
      vpc_attributes -> 'PrivateIpAddress' -> 'IpAddress'  as "Private IP Address",
      vpc_attributes ->> 'VSwitchId' as "Switch ID"
    from
      alicloud_ecs_instance
    where
      arn = $1;
  EOQ
}
