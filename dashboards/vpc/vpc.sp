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
  icon  = "rule"
  color = local.networking_color
}

category "vpc_route_table" {
  title = "VPC Route Table"
  icon  = "table_rows"
  color = local.networking_color
}

category "vpc_vswitch" {
  title = "VPC VSwitch"
  color = local.networking_color
  icon  = "share"
}

category "vpc_vpc" {
  title = "VPC"
  href  = "/alicloud_insights.dashboard.vpc_detail?input.vpc_id={{.properties.'VPC ID' | @uri}}"
  icon  = "cloud"
  color = local.networking_color
}
