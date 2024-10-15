locals {
  vpc_common_tags = {
    service = "AliCloud/VPC"
  }
}

category "vpc_dhcp_option_set" {
  title = "VPC DHCP Option Set"
  color = local.networking_color
  icon  = "text:DHCP"
}

category "vpc_flow_log" {
  title = "VPC Flow Log"
  color = local.networking_color
  icon  = "export_notes"
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
  title = "VPC vSwitch"
  color = local.networking_color
  href  = "/alicloud_insights.dashboard.vpc_vswitch_detail?input.vswitch_id={{.properties.'VSwitch ID' | @uri}}"
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
