locals {
  ram_common_tags = {
    service = "AliCloud/RAM"
  }
}

category "ram_policy" {
  title = "RAM Policy"
  color = local.ram_color
  icon  = "rule_folder"
}

category "ram_role" {
  title = "RAM Role"
  href  = "/alicloud_insights.dashboard.ram_role_detail?input.role_arn={{.properties.'ARN' | @uri}}"
  icon  = "engineering"
  color = local.ram_color
}