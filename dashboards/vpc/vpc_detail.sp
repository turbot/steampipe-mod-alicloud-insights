dashboard "alicloud_vpc_detail" {

  title         = "Alicloud VPC Detail"
  documentation = file("./dashboards/vpc/docs/vpc_detail.md")

  tags = merge(local.vpc_common_tags, {
    type = "Detail"
  })

  input "vpc_id" {
    title = "Select a VPC:"
    query = query.alicloud_vpc_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.alicloud_vpc_ipv4_count
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

    card {
      width = 2
      query = query.alicloud_vpc_ipv6_count
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

    card {
      width = 2
      query = query.alicloud_vpc_vswitch_count
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

    card {
      width = 2
      query = query.alicloud_vpc_is_default
      args = {
        vpc_id = self.input.vpc_id.value
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
        query = query.alicloud_vpc_overview
        args = {
          vpc_id = self.input.vpc_id.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.alicloud_vpc_tags
        args = {
          vpc_id = self.input.vpc_id.value
        }
      }

    }

    container {

      width = 6

      table {
        title = "CIDR Blocks"
        query = query.alicloud_vpc_cidr_blocks
        args = {
          vpc_id = self.input.vpc_id.value
        }
      }

      table {
        title = "DHCP Options"
        query = query.alicloud_vpc_dhcp_options
        args = {
          vpc_id = self.input.vpc_id.value
        }
      }

    }

  }

  container {

    title = "Vswitches"

    chart {
      title = "vSwitches by AZ"
      type  = "column"
      width = 4
      query = query.alicloud_vpc_vswitch_by_az
      args = {
        vpc_id = self.input.vpc_id.value
      }

    }

    table {
      query = query.alicloud_vpc_vswitches_detail
      width = 8
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

  }

  container {

    table {
      title = "Route Tables"
      query = query.alicloud_vpc_route_tables_detail
      width = 6
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

    table {
      title = "Routes"
      query = query.alicloud_vpc_routes_detail
      width = 6
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

  }

  container {

    title = "NACLs"


    flow {
      base  = flow.nacl_flow
      title = "Ingress NACLs"
      width = 6
      query = query.alicloud_vpc_ingress_nacl_sankey
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }


    flow {
      base  = flow.nacl_flow
      title = "Egress NACLs"
      width = 6
      query = query.alicloud_vpc_egress_nacl_sankey
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }


  }

  container {

    table {
      title = "Security Groups"

      query = query.alicloud_vpc_security_groups_detail
      width = 6
      args = {
        vpc_id = self.input.vpc_id.value
      }
    }

    table {
      title = "Gateways"
      query = query.alicloud_vpc_gateways_detail
      width = 6
      args = {
        vpc_id = self.input.vpc_id.value
      }
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

query "alicloud_vpc_input" {
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

query "alicloud_vpc_ipv4_count" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_ipv6_count" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_vswitch_count" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_is_default" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_overview" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_tags" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_cidr_blocks" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_dhcp_options" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_vswitch_by_az" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_vswitches_detail" {
  sql = <<-EOQ
    with vSwitches as (
      select
        vswitch_id,
        tags,
        cidr_block,
        zone_id,
        available_ip_address_count,
        power(2, 32 - masklen(cidr_block :: cidr)) -1 as raw_size
      from
        alicloud_vpc_vswitch
    )
    select
      vswitch_id as "vSwitch ID",
      tags ->> 'Name' as "Name",
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

  param "vpc_id" {}
}

query "alicloud_vpc_route_tables_detail" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_routes_detail" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_security_groups_detail" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_gateways_detail" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_ingress_nacl_sankey" {
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

  param "vpc_id" {}
}

query "alicloud_vpc_egress_nacl_sankey" {
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

  param "vpc_id" {}
}


