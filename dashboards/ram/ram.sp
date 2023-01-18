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

category "ram_policy_action" {
  title = "RAM Policy Action"
  color = local.ram_color
  // href  = "/alicloud_insights.dashboard.ram_action_glob_report?input.action_glob={{.title | @uri}}"
  icon = "electric_bolt"
}

category "ram_policy_condition" {
  title = "RAM Policy Condition"
  color = local.ram_color
  icon  = "help"
}

category "ram_policy_condition_key" {
  title = "RAM Policy Condition Key"
  color = local.ram_color
  icon  = "vpn_key"
}

category "ram_policy_condition_value" {
  title = "RAM Policy Condition Value"
  color = local.ram_color
  icon  = "numbers"
}

category "ram_policy_notaction" {
  title = "RAM Policy NotAction"
  color = local.ram_color
  icon  = "flash_off"
}

category "ram_policy_notresource" {
  title = "RAM Policy NotResource"
  color = local.ram_color
  icon  = "bookmark_remove"
}

category "ram_policy_resource" {
  title = "RAM Policy Resource"
  color = local.ram_color
  icon  = "bookmark"
}

category "ram_policy_statement" {
  title = "RAM Policy Statement"
  color = local.ram_color
  icon  = "assignment"
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
