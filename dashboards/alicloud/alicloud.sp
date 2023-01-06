locals {
  alicloud_common_tags = {
    service = "AliCloud"
  }
}

category "availability_zone" {
  title = "Availability Zone"
  color = local.networking_color
  icon  = "apartment"
}