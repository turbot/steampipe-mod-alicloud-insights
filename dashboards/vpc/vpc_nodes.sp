
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

