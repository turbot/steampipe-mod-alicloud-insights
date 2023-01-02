locals {
  alicloud_common_tags = {
    service = "AliCloud"
  }
}

category "availability_zone" {
  title = "Availability Zone"
  icon  = "apartment"
  color = local.networking_color
}