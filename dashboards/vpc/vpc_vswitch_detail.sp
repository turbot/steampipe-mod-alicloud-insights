dashboard "vpc_vswitch_detail" {

  title         = "AliCloud VPC vSwitch Detail"
  documentation = file("./dashboards/vpc/docs/vpc_vswitch_detail.md")

  tags = merge(local.vpc_common_tags, {
    type = "Detail"
  })

  input "vswitch_id" {
    title = "Select a vSwitch:"
    query = query.vpc_vswitch_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.vpc_vswitch_available_ip_address_count
      args  = [self.input.vswitch_id.value]
    }

    card {
      width = 2
      query = query.vpc_vswitch_cidr_block
      args  = [self.input.vswitch_id.value]
    }

    card {
      width = 2
      query = query.vpc_vswitch_status
      args  = [self.input.vswitch_id.value]
    }

  }

  with "ecs_autoscaling_groups_for_vpc_vswitch" {
    query = query.ecs_autoscaling_groups_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "ecs_instances_for_vpc_vswitch" {
    query = query.ecs_instances_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "ecs_network_interfaces_for_vpc_vswitch" {
    query = query.ecs_network_interfaces_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "rds_instances_for_vpc_vswitch" {
    query = query.rds_instances_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "vpc_nat_gateways_for_vpc_vswitch" {
    query = query.vpc_nat_gateways_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "vpc_network_acls_for_vpc_vswitch" {
    query = query.vpc_network_acls_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "vpc_route_tables_for_vpc_vswitch" {
    query = query.vpc_route_tables_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  with "vpc_vpcs_for_vpc_vswitch" {
    query = query.vpc_vpcs_for_vpc_vswitch
    args  = [self.input.vswitch_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.ecs_autoscaling_group
        args = {
          ecs_autoscaling_group_ids = with.ecs_autoscaling_groups_for_vpc_vswitch.rows[*].autoscaling_group_id
        }
      }

      node {
        base = node.ecs_instance
        args = {
          ecs_instance_arns = with.ecs_instances_for_vpc_vswitch.rows[*].instance_arn
        }
      }

      node {
        base = node.ecs_network_interface
        args = {
          ecs_network_interface_ids = with.ecs_network_interfaces_for_vpc_vswitch.rows[*].eni_id
        }
      }

      node {
        base = node.rds_instance
        args = {
          rds_instance_arns = with.rds_instances_for_vpc_vswitch.rows[*].rds_instance_arn
        }
      }

      node {
        base = node.vpc_nat_gateway
        args = {
          vpc_nat_gateway_ids = with.vpc_nat_gateways_for_vpc_vswitch.rows[*].gateway_id
        }
      }

      node {
        base = node.vpc_network_acl
        args = {
          vpc_network_acl_ids = with.vpc_network_acls_for_vpc_vswitch.rows[*].network_acl_id
        }
      }

      node {
        base = node.vpc_route_table
        args = {
          vpc_route_table_ids = with.vpc_route_tables_for_vpc_vswitch.rows[*].route_table_id
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = with.vpc_vpcs_for_vpc_vswitch.rows[*].vpc_id
        }
      }

      node {
        base = node.vpc_vswitch
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
        }
      }

      edge {
        base = edge.vpc_vpc_to_vpc_vswitch
        args = {
          vpc_vpc_ids = with.vpc_vpcs_for_vpc_vswitch.rows[*].vpc_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_ecs_autoscaling_group
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_ecs_instance
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_ecs_network_interface
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_nat_gateway
        args = {
          vpc_nat_gateway_ids = with.vpc_nat_gateways_for_vpc_vswitch.rows[*].gateway_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_rds_instance
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_vpc_network_acl
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_vpc_route_table
        args = {
          vpc_vswitch_ids = [self.input.vswitch_id.value]
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
        query = query.vpc_vswitch_overview
        args  = [self.input.vswitch_id.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.vpc_vswitch_tags
        args  = [self.input.vswitch_id.value]
      }

    }
    container {

      width = 6

      table {
        title = "Launched Resources"
        query = query.vpc_vswitch_association
        args  = [self.input.vswitch_id.value]

        column "link" {
          display = "none"
        }

        column "Title" {
          href = "{{ .link }}"
        }

      }

    }
  }

}

# Input queries

query "vpc_vswitch_input" {
  sql = <<-EOQ
    select
      title as label,
      vswitch_id as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'vswitch_id', vswitch_id
      ) as tags
    from
      alicloud_vpc_vswitch
    order by
      title;
  EOQ
}

# with queries

query "vpc_network_acls_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      network_acl_id as network_acl_id
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = $1
      and network_acl_id is not null;
  EOQ
}

query "vpc_nat_gateways_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      nat_gateway_id as gateway_id
    from
      alicloud_vpc_nat_gateway
    where
      nat_gateway_private_info ->> 'VswitchId' = $1;
  EOQ
}

query "ecs_autoscaling_groups_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      scaling_group_id as autoscaling_group_id
    from
      alicloud_ecs_autoscaling_group,
      jsonb_array_elements_text(vswitch_ids) as v
    where
      v = $1;
  EOQ
}

query "vpc_route_tables_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      route_table_id as route_table_id
    from
      alicloud_vpc_route_table,
      jsonb_array_elements_text(vswitch_ids) as b
    where
      b = $1;
  EOQ
}

query "ecs_instances_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      i.arn as instance_arn
    from
      alicloud_ecs_instance as i
    where
      i.vpc_attributes ->> 'VSwitchId' = $1;
  EOQ
}

query "ecs_network_interfaces_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      network_interface_id as eni_id
    from
      alicloud_ecs_network_interface
    where
      vswitch_id = $1;
  EOQ
}

query "rds_instances_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      arn as rds_instance_arn
    from
      alicloud_rds_instance
    where
      vswitch_id = $1;
  EOQ
}

query "vpc_vpcs_for_vpc_vswitch" {
  sql = <<-EOQ
    select
      vpc_id as vpc_id
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = $1;
  EOQ
}

# card queries

query "vpc_vswitch_available_ip_address_count" {
  sql = <<-EOQ
    select
      'IP Address Count' as label,
      available_ip_address_count as value
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = $1
  EOQ
}

query "vpc_vswitch_cidr_block" {
  sql = <<-EOQ
    select
      'CIDR Block' as label,
      cidr_block as value
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = $1
  EOQ
}

query "vpc_vswitch_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      status as value
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = $1
  EOQ
}

# table queries

query "vpc_vswitch_overview" {
  sql = <<-EOQ
    select
      vswitch_id as "vSwitch ID",
      vpc_id as "VPC ID",
      owner_id as "Owner ID",
      zone_id as "Zone ID",
      title as "Title",
      region as "Region",
      zone_id as "Zone ID",
      account_id as "Account ID"
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = $1
  EOQ
}

query "vpc_vswitch_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      alicloud_vpc_vswitch,
      jsonb_array_elements(tags_src) as tag
    where
      vswitch_id = $1
    order by
      tag ->> 'Key';
  EOQ
}

query "vpc_vswitch_association" {
  sql = <<-EOQ

    -- ECS instances
    select
      i.title as "Title",
      'alicloud_ecs_instance' as "Type",
      i.arn as "ARN",
      '${dashboard.ecs_instance_detail.url_path}?input.instance_arn=' || arn as link
    from
      alicloud_ecs_instance as i
      join alicloud_vpc_vswitch as s on s.vpc_id = i.vpc_id
    where
      s.vswitch_id = $1

    -- RDS DB Instances
    union all
    select
      title as "Title",
      'alicloud_rds_instance' as "Type",
      arn as "ARN",
      '${dashboard.rds_instance_detail.url_path}?input.db_instance_arn=' || arn as link
    from
      alicloud_rds_instance
    where
      vswitch_id = $1

    -- Network ACLs
    union all
    select
      a.title as "Title",
      'alicloud_vpc_network_acl' as "Type",
      v.network_acl_id as "ID",
      null as link
    from
      alicloud_vpc_vswitch as v,
      alicloud_vpc_network_acl as a
    where
      vswitch_id = $1
      and v.network_acl_id is not null
      and v.network_acl_id = a.network_acl_id

    -- Route Tables
    union all
    select
      title as "Title",
      'alicloud_vpc_route_table' as "Type",
      route_table_id as "ID",
      null as link
    from
      alicloud_vpc_route_table,
      jsonb_array_elements_text(vswitch_ids) as b
    where
      b = $1
      and route_table_id is not null;
  EOQ
}
