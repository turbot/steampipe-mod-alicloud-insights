
node "vpc_availability_zone" {
  category = category.availability_zone

  sql = <<-EOQ
    select
      distinct on (zone_id)
      zone_id as id,
      jsonb_build_object(
        'Availability Zone ID', zone_id,
        'Region', region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_vpc_vswitch
    where
      vpc_id = any($1)
  EOQ

  param "vpc_vpc_ids" {}
}

node "vpc_eip" {
  category = category.vpc_eip

  sql = <<-EOQ
  select
      arn as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'Allocation Id', allocation_id,
        'IP Address', ip_address,
        'Status', status,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_vpc_eip
    where
      arn = any($1 ::text[]);
  EOQ

  param "vpc_eip_arns" {}
}

node "vpc_nat_gateway" {
  category = category.vpc_nat_gateway

  sql = <<-EOQ
    select
      nat_gateway_id as id,
      title as title,
      jsonb_build_object(
        'NAT Gateway ID', nat_gateway_id,
        'Status', status,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_vpc_nat_gateway
    where
      nat_gateway_id = any($1);
  EOQ

  param "vpc_nat_gateway_ids" {}
}

node "vpc_network_acl" {
  category = category.vpc_network_acl

  sql = <<-EOQ
    select
      network_acl_id as id,
      title as title,
      jsonb_build_object(
        'Network Acl Entry Id', i ->> 'NetworkAclEntryId',
        'Source Cidr IP', i ->> 'SourceCidrIp',
        'Region', region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_vpc_network_acl,
      jsonb_array_elements(ingress_acl_entries) as i
    where
      network_acl_id = any($1);
  EOQ

  param "vpc_network_acl_ids" {}
}

node "vpc_route_table" {
  category = category.vpc_route_table

  sql = <<-EOQ
    select
      route_table_id as id,
      title as title,
      jsonb_build_object(
        'Owner ID', owner_id,
        'Region', region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_vpc_route_table
    where
      route_table_id = any($1);
  EOQ

  param "vpc_route_table_ids" {}
}

node "vpc_vswitch" {
    category = category.vpc_vswitch

  sql = <<-EOQ
    select
      vswitch_id as id,
      title as title,
      jsonb_build_object(
        'Subnet ID', vswitch_id,
        'VPC ID', vpc_id,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = any($1 ::text[]);
  EOQ

  param "vpc_vswitch_ids" {}
}

node "vpc_vpn_gateway" {
  category = category.vpc_vpn_gateway

  sql = <<-EOQ
    select
      vpn_gateway_id as id,
      title as title,
      jsonb_build_object(
        'ID', vpn_gateway_id,
        'Status',status,
        'Region', region,
        'Account ID', account_id
      ) as properties
    from
      alicloud_vpc_vpn_gateway
    where
      vpc_id = any($1);
  EOQ

  param "vpc_vpc_ids" {}
}

node "vpc_vpc" {
  category = category.vpc_vpc

  sql = <<-EOQ
    select
      vpc_id as id,
      title as title,
      jsonb_build_object(
        'ARN', arn,
        'VPC ID', vpc_id,
        'Is Default', is_default,
        'Status', status,
        'CIDR Block', cidr_block,
        'DHCP Options ID', dhcp_options_set_id,
        'Owner ID', owner_id,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_vpc
    where
      vpc_id = any($1 ::text[]);
  EOQ

  param "vpc_vpc_ids" {}
}

