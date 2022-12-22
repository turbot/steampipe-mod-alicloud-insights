locals {
  vpc_common_tags = {
    service = "AliCloud/VPC"
  }
}

category "vpc_eip" {
  title = "VPC EIP"
  color = local.networking_color
  icon  = "swipe-right-alt"
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
