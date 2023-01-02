dashboard "vpc_detail" {

  title         = "AliCloud VPC Detail"
  documentation = file("./dashboards/vpc/docs/vpc_detail.md")

  tags = merge(local.vpc_common_tags, {
    type = "Detail"
  })

  input "vpc_id" {
    title = "Select a VPC:"
    query = query.vpc_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.vpc_ipv4_count
      args  = [self.input.vpc_id.value]
    }

    card {
      width = 2
      query = query.vpc_ipv6_count
      args  = [self.input.vpc_id.value]
    }

    card {
      width = 2
      query = query.vpc_vswitch_count
      args  = [self.input.vpc_id.value]
    }

    card {
      width = 2
      query = query.vpc_is_default
      args  = [self.input.vpc_id.value]
    }

  }

  with "ecs_instances" {
    query = query.vpc_vpc_ecs_instances
    args  = [self.input.vpc_id.value]
  }

  with "ecs_network_interfaces" {
    query = query.vpc_vpc_ecs_network_interfaces
    args  = [self.input.vpc_id.value]
  }

  with "rds_db_instances" {
    query = query.vpc_vpc_rds_db_instances
    args  = [self.input.vpc_id.value]
  }

  with "vpc_route_tables" {
    query = query.vpc_vpc_vpc_route_tables
    args  = [self.input.vpc_id.value]
  }

  with "vpc_nat_gateways" {
    query = query.vpc_vpc_vpc_nat_gateways
    args  = [self.input.vpc_id.value]
  }

  with "ecs_security_groups" {
    query = query.vpc_vpc_ecs_security_groups
    args  = [self.input.vpc_id.value]
  }

  with "vpc_vswitch" {
    query = query.vpc_vpc_vpc_vswitch
    args  = [self.input.vpc_id.value]
  }

  container {
    graph {
      title = "Relationships"
      width = 12
      type  = "graph"

      node {
        base = node.vpc_availability_zone
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      node {
        base = node.ecs_instance
        args = {
          ecs_instance_arns = with.ecs_instances.rows[*].instance_arn
        }
      }

      node {
        base = node.ecs_network_interface
        args = {
          ecs_network_interface_ids = with.ecs_network_interfaces.rows[*].eni_id
        }
      }

      node {
        base = node.rds_instance
        args = {
          rds_db_instance_arns = with.rds_db_instances.rows[*].rds_instance_arn
        }
      }

      node {
        base = node.vpc_nat_gateway
        args = {
          vpc_nat_gateway_ids = with.vpc_nat_gateways.rows[*].gateway_id
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
          vpc_vswitch_ids = with.vpc_vswitch.rows[*].vswitch_id
        }
      }

      node {
        base = node.vpc_route_table
        args = {
          vpc_route_table_ids = with.vpc_route_tables.rows[*].route_table_id
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      node {
        base = node.vpc_vpn_gateway
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      edge {
        base = edge.vpc_availability_zone_to_vpc_vswitch
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      edge {
        base = edge.vpc_vswitch_to_ecs_instance
        args = {
          vpc_vswitch_ids = with.vpc_vswitch.rows[*].vswitch_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_ecs_network_interface
        args = {
          vpc_vswitch_ids = with.vpc_vswitch.rows[*].vswitch_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_rds_instance
        args = {
          vpc_vswitch_ids = with.vpc_vswitch.rows[*].vswitch_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_vpc_route_table
        args = {
          vpc_vswitch_ids = with.vpc_vswitch.rows[*].vswitch_id
        }
      }

      edge {
        base = edge.vpc_vswitch_to_nat_gateway
        args = {
          vpc_nat_gateway_ids = with.vpc_nat_gateways.rows[*].gateway_id
        }
      }

      edge {
        base = edge.vpc_vpc_to_vpc_availability_zone
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      edge {
        base = edge.vpc_vpc_to_vpc_route_table
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      edge {
        base = edge.vpc_vpc_to_ecs_security_group
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
        }
      }

      edge {
        base = edge.vpc_vpc_to_vpc_vpn_gateway
        args = {
          vpc_vpc_ids = [self.input.vpc_id.value]
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
        query = query.vpc_overview
        args  = [self.input.vpc_id.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.vpc_tags
        args  = [self.input.vpc_id.value]
      }

    }

    container {

      width = 6

      table {
        title = "CIDR Blocks"
        query = query.vpc_cidr_blocks
        args  = [self.input.vpc_id.value]
      }

      table {
        title = "DHCP Options"
        query = query.vpc_dhcp_options
        args  = [self.input.vpc_id.value]
      }

    }

  }

  container {

    title = "vSwitches"

    chart {
      title = "vSwitches by Zone"
      type  = "column"
      width = 4
      query = query.vpc_vswitch_by_az
      args  = [self.input.vpc_id.value]

    }

    table {
      query = query.vpc_vswitches_detail
      width = 8
      args  = [self.input.vpc_id.value]
    }

  }

  container {

    table {
      title = "Route Tables"
      query = query.vpc_route_tables_detail
      width = 6
      args  = [self.input.vpc_id.value]
    }

    table {
      title = "Routes"
      query = query.vpc_routes_detail
      width = 6
      args  = [self.input.vpc_id.value]
    }

  }

  container {

    title = "NACLs"


    flow {
      base  = flow.nacl_flow
      title = "Ingress NACLs"
      width = 6
      query = query.vpc_ingress_nacl_sankey
      args  = [self.input.vpc_id.value]
    }


    flow {
      base  = flow.nacl_flow
      title = "Egress NACLs"
      width = 6
      query = query.vpc_egress_nacl_sankey
      args  = [self.input.vpc_id.value]
    }


  }

  container {

    table {
      title = "Security Groups"

      query = query.vpc_security_groups_detail
      width = 6
      args  = [self.input.vpc_id.value]
    }

    table {
      title = "Gateways"
      query = query.vpc_gateways_detail
      width = 6
      args  = [self.input.vpc_id.value]
    }

  }

}




flow "nacl_flow" {
  width = 6
  type  = "sankey"


  category "drop" {
    color = "alert"
  }

  category "accept" {
    color = "ok"
  }

}

query "vpc_input" {
  sql = <<-EOQ
    select
      title as label,
      vpc_id as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'vpc_id', vpc_id
      ) as tags
    from
      alicloud_vpc
    order by
      title;
  EOQ
}

query "vpc_ipv4_count" {
  sql = <<-EOQ
    with cidrs as (
      select
        power(2, 32 - masklen(cidr_block)) as num_ips
      from
        alicloud_vpc
      where
        vpc_id = $1
      union all
      select
        power(2, 32 - masklen(b:: cidr)) as num_ips
      from
        alicloud_vpc,
        jsonb_array_elements_text(secondary_cidr_blocks) as b
      where
        vpc_id = $1
    )
    select
      sum(num_ips) as "IPv4 Addresses"
    from
      cidrs;
  EOQ

}

query "vpc_ipv6_count" {
  sql = <<-EOQ
    with cidrs as (
      select
        power(2, 128 - masklen((b ->> 'Ipv6CidrBlock'):: cidr)) as num_ips
      from
        alicloud_vpc,
        jsonb_array_elements(ipv6_cidr_blocks) as b
      where
        vpc_id = $1
    )
    select
      sum(num_ips) as "IPv6 Addresses"
    from
      cidrs;
  EOQ

}

query "vpc_vswitch_count" {
  sql = <<-EOQ
    select
      'vSwitches' as label,
      count(*) as value,
      case when count(*) > 0 then 'ok' else 'alert' end as type
    from
      alicloud_vpc_vswitch
    where
      vpc_id = $1;
  EOQ

}

query "vpc_is_default" {
  sql = <<-EOQ
    select
      'Default VPC' as label,
      case when not is_default then 'ok' else 'Default VPC' end as value,
      case when not is_default then 'ok' else 'alert' end as type
    from
      alicloud_vpc
    where
      vpc_id = $1;
  EOQ

}

# with queries

query "vpc_vpc_ecs_instances" {
  sql   = <<-EOQ
    select
      arn as instance_arn
    from
      alicloud_ecs_instance as i
    where
      vpc_id = $1;
  EOQ
}

query "vpc_vpc_ecs_network_interfaces" {
  sql   = <<-EOQ
    select
      network_interface_id as eni_id
    from
      alicloud_ecs_network_interface
    where
      vpc_id = $1;
  EOQ
}

query "vpc_vpc_rds_db_instances" {
  sql   = <<-EOQ
    select
      arn as rds_instance_arn
    from
      alicloud_rds_instance
    where
      vpc_id = $1;
  EOQ
}

query "vpc_vpc_vpc_nat_gateways" {
    sql   = <<-EOQ
    select
      nat_gateway_id as gateway_id
    from
      alicloud_vpc_nat_gateway
    where
      vpc_id = $1;
  EOQ
}

query "vpc_vpc_ecs_security_groups" {
  sql   = <<-EOQ
    select
      security_group_id as security_group_id
    from
      alicloud_ecs_security_group
    where
      vpc_id = $1;
  EOQ
}

query "vpc_vpc_vpc_vswitch" {
  sql   = <<-EOQ
    select
      vswitch_id as vswitch_id
    from
      alicloud_vpc_vswitch
    where
      vpc_id = $1;
  EOQ
}

query "vpc_vpc_vpc_route_tables" {
  sql   = <<-EOQ
    select
      route_table_id as route_table_id
    from
      alicloud_vpc_route_table
    where
      vpc_id = $1;
  EOQ
}

query "vpc_overview" {
  sql = <<-EOQ
    select
      vpc_id as "VPC ID",
      title as "Title",
      region as "Region",
      account_id as "Account ID"
    from
      alicloud_vpc
    where
      vpc_id = $1
  EOQ

}

query "vpc_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      alicloud_vpc,
      jsonb_array_elements(tags_src) as tag
    where
      vpc_id = $1
    order by
      tag ->> 'Key';
  EOQ

}

query "vpc_cidr_blocks" {
  sql = <<-EOQ
    select
      cidr_block as "CIDR Block",
      power(2, 32 - masklen(cidr_block)) as "Total IPs"
    from
      alicloud_vpc
    where
      vpc_id = $1
    union all
    select
      b::cidr as "CIDR Block",
      power(2, 32 - masklen(b:: cidr)) as "Total IPs"
    from
      alicloud_vpc,
      jsonb_array_elements_text(secondary_cidr_blocks) as b
    where
      vpc_id = $1
    union all
    select
      (b ->> 'Ipv6CidrBlock'):: cidr as "CIDR Block",
      power(2, 128 - masklen((b ->> 'Ipv6CidrBlock'):: cidr)) as "Total IPs"
    from
      alicloud_vpc,
      jsonb_array_elements(ipv6_cidr_blocks) as b
    where
      vpc_id = $1;
  EOQ

}

query "vpc_dhcp_options" {
  sql = <<-EOQ
    select
      distinct dhcp_options_set_id as "DHCP Options Set ID",
      name as "Name",
      status as "Status",
      domain_name as "Domain Name",
      domain_name_servers as "Domain Name Servers",
      boot_file_name as "Boot File Name",
      tftp_server_name as "TFTP Server Name"
    from
      alicloud_vpc_dhcp_options_set,
      jsonb_array_elements(associate_vpcs) as v
    where
      v ->> 'VpcId' = $1
    order by
      dhcp_options_set_id;
  EOQ

}

query "vpc_vswitch_by_az" {
  sql = <<-EOQ
    select
      zone_id,
      count(*)
    from
      alicloud_vpc_vswitch
    where
      vpc_id = $1
    group by
      zone_id
    order by
      zone_id;
  EOQ

}

query "vpc_vswitches_detail" {
  sql = <<-EOQ
    with vSwitches as (
      select
        vswitch_id,
        name,
        cidr_block,
        zone_id,
        available_ip_address_count,
        power(2, 32 - masklen(cidr_block :: cidr)) -1 as raw_size
      from
        alicloud_vpc_vswitch
      where
        vpc_id = $1
    )
    select
      vswitch_id as "vSwitch ID",
      name as "Name",
      cidr_block as "CIDR Block",
      zone_id as "Zone ID",
      available_ip_address_count as "Available IPs",
      power(2, 32 - masklen(cidr_block :: cidr)) -1 as "Total IPs",
      round(100 * (available_ip_address_count / (raw_size))::numeric, 2) as "% Free"
    from
      vSwitches
    order by
      vswitch_id;
  EOQ

}

query "vpc_route_tables_detail" {
  sql = <<-EOQ
    select
      route_table_id as "Route Table ID",
      name as "Name"
    from
      alicloud_vpc_route_table
    where
      vpc_id = $1
    order by
      route_table_id;
  EOQ

}

query "vpc_routes_detail" {
  sql = <<-EOQ
    select
      route_table_id as "Route Table ID",
      name as "Name",
      r ->> 'Status' as "Status",
      r ->> 'InstanceId' as "Gateway",
      r ->> 'DestinationCidrBlock' as "Destination CIDR",
      case
        when v is null then vpc_id
        else v
      end as "Associated To"
    from
      alicloud_vpc_route_table,
      jsonb_array_elements(route_entries) as r,
      jsonb_array_elements_text(vswitch_ids) as v
    where
      vpc_id = $1
    order by
      route_table_id,
      "Associated To";
  EOQ

}

query "vpc_security_groups_detail" {
  sql = <<-EOQ
    select
      name as "Group Name",
      security_group_id as "Group ID",
      creation_time as "Creation Time",
      description as "Description"
    from
      alicloud_ecs_security_group
    where
      vpc_id = $1;
  EOQ

}

query "vpc_gateways_detail" {
  sql = <<-EOQ
    select
      vpn_gateway_id as "ID",
      name as "Name",
      'alicloud_vpc_vpn_gateway' as "Type",
      status as "Status"
    from
      alicloud_vpc_vpn_gateway
     where
     vpc_id = $1
    union all
    select
      nat_gateway_id as "ID",
      name as "Name",
      'alicloud_vpc_nat_gateway' as "Type",
      status as "Status"
    from
      alicloud_vpc_nat_gateway
     where
       vpc_id = $1;
  EOQ

}

query "vpc_ingress_nacl_sankey" {
  sql = <<-EOQ
    with aces as (
      select
        title,
        network_acl_id,
        e ->> 'SourceCidrIp' as cidr_block,
        SPLIT_PART(e ->> 'Port','/',2) as to_port,
        SPLIT_PART(e ->> 'Port','/',1) as from_port,
        e ->> 'Policy' as rule_action,
        e ->> 'NetworkAclEntryName' as rule_name,
        e ->> 'Protocol' as protocol,
        case when e ->> 'Policy' = 'accept' then 'Accept ' else 'Drop ' end ||
          case
              when e->>'Protocol' = 'all' then 'All Traffic'
              when e->>'Protocol' = 'icmp' then 'All ICMP'
              when e->>'Protocol' = 'tcp' and (e ->> 'Port' = '1/1' or e ->> 'Port' = '1/65535') then 'All TCP'
              when e->>'Protocol' = 'udp' and (e ->> 'Port' = '1/1' or e ->> 'Port' = '1/65535') then 'All UDP'
              when e->>'Protocol' = 'tcp' and SPLIT_PART(e ->> 'Port','/',2) = SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '/TCP')
               when e->>'Protocol' = 'udp' and SPLIT_PART(e ->> 'Port','/',2) = SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '/UDP')

              when e->>'Protocol' = 'tcp' and SPLIT_PART(e ->> 'Port','/',2) <> SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '-', SPLIT_PART(e ->> 'Port','/',1), '/TCP')
              when e->>'Protocol' = 'udp' and SPLIT_PART(e ->> 'Port','/',2) <> SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '-', SPLIT_PART(e ->> 'Port','/',1), '/UDP')

              else concat('Procotol: ', e->>'Protocol')
        end as rule_description,
        r ->> 'ResourceId' as associated_id
      from
        alicloud_vpc_network_acl,
        jsonb_array_elements(ingress_acl_entries) as e,
        jsonb_array_elements(resources) as r
      where
        vpc_id = $1
    )
    -- CIDR Nodes
    select
      distinct cidr_block as id,
      cidr_block as title,
      'cidr_block' as category,
      null as from_id,
      null as to_id
    from aces

    -- Rule Nodes
    union select
      concat(network_acl_id,'_',rule_name) as id,
      rule_description as title,
      'rule' as category,
      null as from_id,
      null as to_id
    from aces

    -- ACL Nodes
    union select
      distinct network_acl_id as id,
      network_acl_id as title,
      'nacl' as category,
      null as from_id,
      null as to_id
    from aces

    -- vswitch node
    union select
      distinct associated_id as id,
      associated_id as title,
      'vswitch' as category,
      null as from_id,
      null as to_id
    from aces

    -- ip -> rule edge
    union select
      null as id,
      null as title,
      rule_action as category,
      cidr_block as from_id,
      concat(network_acl_id,'_',rule_name) as to_id
    from aces

    -- rule -> NACL edge
    union select
      null as id,
      null as title,
      rule_action as category,
      concat(network_acl_id,'_',rule_name) as from_id,
      network_acl_id as to_id
    from aces

    -- nacl -> vswitch edge
    union select
      null as id,
      null as title,
      'attached' as category,
      network_acl_id as from_id,
      associated_id as to_id
    from aces
  EOQ

}

query "vpc_egress_nacl_sankey" {
  sql = <<-EOQ
    with aces as (
      select
        title,
        network_acl_id,
        e ->> 'SourceCidrIp' as cidr_block,
        SPLIT_PART(e ->> 'Port','/',2) as to_port,
        SPLIT_PART(e ->> 'Port','/',1) as from_port,
        e ->> 'Policy' as rule_action,
        e ->> 'NetworkAclEntryName' as rule_name,
        e ->> 'Protocol' as protocol,
        case when e ->> 'Policy' = 'accept' then 'Accept ' else 'Drop ' end ||
          case
              when e->>'Protocol' = 'all' then 'All Traffic'
              when e->>'Protocol' = 'icmp' then 'All ICMP'
              when e->>'Protocol' = 'tcp' and (e ->> 'Port' = '1/1' or e ->> 'Port' = '1/65535') then 'All TCP'
              when e->>'Protocol' = 'udp' and (e ->> 'Port' = '1/1' or e ->> 'Port' = '1/65535') then 'All UDP'
              when e->>'Protocol' = 'tcp' and SPLIT_PART(e ->> 'Port','/',2) = SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '/TCP')
               when e->>'Protocol' = 'udp' and SPLIT_PART(e ->> 'Port','/',2) = SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '/UDP')

              when e->>'Protocol' = 'tcp' and SPLIT_PART(e ->> 'Port','/',2) <> SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '-', SPLIT_PART(e ->> 'Port','/',1), '/TCP')
              when e->>'Protocol' = 'udp' and SPLIT_PART(e ->> 'Port','/',2) <> SPLIT_PART(e ->> 'Port','/',1)
                then  concat(SPLIT_PART(e ->> 'Port','/',2), '-', SPLIT_PART(e ->> 'Port','/',1), '/UDP')

              else concat('Procotol: ', e->>'Protocol')
        end as rule_description,
        r ->> 'ResourceId' as associated_id
      from
        alicloud_vpc_network_acl,
        jsonb_array_elements(ingress_acl_entries) as e,
        jsonb_array_elements(resources) as r
      where
        vpc_id = $1
    )
   -- Subnet Nodes
    select
      distinct associated_id as id,
      associated_id as title,
      'vswitch' as category,
      null as from_id,
      null as to_id,
      0 as depth
    from aces

    -- ACL Nodes
    union select
      distinct network_acl_id as id,
      network_acl_id as title,
      'nacl' as category,
      null as from_id,
      null as to_id,
      1 as depth
    from aces

    -- Rule Nodes
    union select
      concat(network_acl_id, '_',rule_name) as id,
      rule_description as title,
      'rule' as category,
      null as from_id,
      null as to_id,
      2 as depth
    from aces

    -- CIDR Nodes
    union select
      distinct cidr_block as id,
      cidr_block as title,
      'cidr_block' as category,
      null as from_id,
      null as to_id,
      3 as depth
    from aces

    -- nacl -> vswitch edge
    union select
      null as id,
      null as title,
      'attached' as category,
      network_acl_id as from_id,
      associated_id as to_id,
      null as depth
    from aces

    -- rule -> NACL edge
    union select
      null as id,
      null as title,
      rule_action as category,
      concat(network_acl_id, '_',rule_name) as from_id,
      network_acl_id as to_id,
      null as depth
    from aces

    -- ip -> rule edge
    union select
      null as id,
      null as title,
      rule_action as category,
      cidr_block as from_id,
      concat(network_acl_id, '_',rule_name) as to_id,
      null as depth
    from aces
  EOQ

}


