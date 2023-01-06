locals {
  vpc_common_tags = {
    service = "AliCloud/VPC"
  }
}

category "vpc_eip" {
  title = "VPC EIP"
  color = local.networking_color
  icon  = "swipe_right_alt"
}

category "vpc_network_acl" {
  title = "VPC Network ACL"
  color = local.networking_color
  icon  = "rule"
}

category "vpc_route_table" {
  title = "VPC Route Table"
  color = local.networking_color
  icon  = "table_rows"
}

category "vpc_nat_gateway" {
  title = "VPC NAT Gateway"
  color = local.networking_color
  icon  = "merge"
}

category "vpc_vswitch" {
  title = "VPC VSwitch"
  color = local.networking_color
  href  = "/alicloud_insights.dashboard.vpc_vswitch_detail?input.vswitch_id={{.properties.'VSWITCH ID' | @uri}}"
  icon  = "lan"
}

category "vpc_vpc" {
  title = "VPC"
  color = local.networking_color
  href  = "/alicloud_insights.dashboard.vpc_detail?input.vpc_id={{.properties.'VPC ID' | @uri}}"
  icon  = "cloud"
}

category "vpc_vpn_gateway" {
  title = "VPC VPN Gateway"
  color = local.networking_color
  icon  = "vpn_lock"
}
