locals {
  ram_common_tags = {
    service = "AliCloud/RAM"
  }
}

category "ram_access_key" {
  title = "RAM Access Key"
  color = local.ram_color
  icon  = "key"
}

category "ram_group" {
  title = "RAM Group"
  color = local.ram_color
  href  = "/alicloud_insights.dashboard.ram_group_detail?input.group_arn={{.properties.'ARN' | @uri}}"
  icon  = "group"
}

category "ram_policy" {
  title = "RAM Policy"
  color = local.ram_color
  icon  = "rule_folder"
}

category "ram_role" {
  title = "RAM Role"
  color = local.ram_color
  href  = "/alicloud_insights.dashboard.ram_role_detail?input.role_arn={{.properties.'ARN' | @uri}}"
  icon  = "engineering"
}

category "ram_user" {
  title = "RAM User"
  color = local.ram_color
  href  = "/alicloud_insights.dashboard.ram_user_detail?input.user_arn={{.properties.'ARN' | @uri}}"
  icon  = "person"
}
