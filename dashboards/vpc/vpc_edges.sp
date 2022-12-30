edge "vpc_vswitch_to_vpc_vpc" {
  title = "vpc"

  sql = <<-EOQ
    select
      vswitch_id as from_id,
      vpc_id as to_id
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = any($1);
  EOQ

  param "vpc_vswitch_ids" {}
}

edge "vpc_vswitch_to_ecs_instance" {
  title = "ecs instance"
  sql   = <<-EOQ
    select
      s.vswitch_id as from_id,
      i.arn as to_id
    from
      alicloud_ecs_instance as i
      join alicloud_vpc_vswitch as s on s.vpc_id = i.vpc_id
    where
      s.vswitch_id = any($1);
  EOQ

  param "vpc_vswitch_ids" {}
}

edge "vpc_vswitch_to_ecs_network_interface" {
    title = "eni"

  sql = <<-EOQ
    select
      vswitch_id as from_id,
      network_interface_id as to_id
    from
      alicloud_ecs_network_interface
    where
      vswitch_id = any($1);
  EOQ

  param "vpc_vswitch_ids" {}
}

edge "vpc_vswitch_to_rds_instance" {
    title = "rds instance"
      sql   = <<-EOQ
    select
      vswitch_id as from_id,
      arn as to_id
    from
      alicloud_rds_instance
    where
      vswitch_id = any($1);
  EOQ
  param "vpc_vswitch_ids" {}
}

edge "vpc_vswitch_to_vpc_network_acl" {
  title = "network acl"
  sql   = <<-EOQ
    select
      vswitch_id as from_id,
      network_acl_id as to_id
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = any($1);
  EOQ
  param "vpc_vswitch_ids" {}
}

edge "vpc_vswitch_to_vpc_route_table" {
    title = "route to"
  sql   = <<-EOQ
    select
      b as from_id,
      route_table_id as to_id
    from
      alicloud_vpc_route_table,
      jsonb_array_elements_text(vswitch_ids) as b
    where
      b = any($1);
  EOQ
  param "vpc_vswitch_ids" {}
}

edge "vpc_vpc_to_vpc_vswitch" {
title = "vswitch"

  sql = <<-EOQ
    select
      vpc_id as from_id,
      vswitch_id as to_id
    from
      alicloud_vpc_vswitch
    where
      vpc_id = any($1);
  EOQ

  param "vpc_vpc_ids" {}
}

edge "vpc_vpc_to_ecs_security_group" {
  title = "security group"

  sql = <<-EOQ
    select
      sg.vpc_id as from_id,
      sg.security_group_id as to_id
    from
      alicloud_ecs_security_group as sg
      join alicloud_vpc as v on v.vpc_id = sg.vpc_id
    where
      v.vpc_id = any($1);
  EOQ
  param "vpc_vpc_ids" {}
}