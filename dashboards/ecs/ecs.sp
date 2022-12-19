locals {
  ecs_common_tags = {
    service = "AliCloud/ECS"
  }
}

category "ecs_disk" {
  title = "ECS Disk"
  href  = "/alicloud_insights.dashboard.ecs_disk_detail?input.disk_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:inbox-stack"
  color = local.storage_color
}

category "ecs_snapshot" {
  title = "ECS Snapshot"
  icon  = "heroicons-outline:inbox-stack"
  color = local.storage_color
}