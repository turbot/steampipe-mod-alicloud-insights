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
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.ecs_instance_type
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.ecs_instance_total_cores
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.ecs_instance_os_type
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.ecs_instance_public_access
      args = {
        arn = self.input.instance_arn.value
      }
    }

    card {
      width = 2
      query = query.ecs_instance_io_optimized
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
        query = query.ecs_instance_overview
        args = {
          arn = self.input.instance_arn.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.ecs_instance_tags
        args = {
          arn = self.input.instance_arn.value
        }
      }
    }
    container {
      width = 6

      table {
        title = " CPU cores"
        query = query.ecs_instance_cpu_cores
        args = {
          arn = self.input.instance_arn.value
        }
      }
    }

  }

  container {
    width = 12

    table {
      title = "Network Interfaces"
      query = query.ecs_instance_network_interfaces
      args = {
        arn = self.input.instance_arn.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "Dedicated Host"
      query = query.ecs_instance_dedicated_host
      args = {
        arn = self.input.instance_arn.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "Security Groups"
      query = query.ecs_instance_security_groups
      args = {
        arn = self.input.instance_arn.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "VPC Details"
      query = query.ecs_instance_vpc
      args = {
        arn = self.input.instance_arn.value
      }
    }

  }

}

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

  param "arn" {}

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

  param "arn" {}

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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
}

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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
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

  param "arn" {}
}
