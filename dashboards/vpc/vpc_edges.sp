
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