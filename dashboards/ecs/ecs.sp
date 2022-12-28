locals {
  ecs_common_tags = {
    service = "AliCloud/ECS"
  }
}

category "ecs_auto_provisioning_group" {
  title = "ECS Autoprovisioning Group"
  icon  = "rocket_launch"
  color = local.compute_color
}

category "ecs_autoscaling_group" {
  title = "ECS Autoscaling Group"
  icon  = "library_add"
  color = local.compute_color
}

category "ecs_launch_template" {
  title = "ECS Launch Template"
  icon  = "text:LT"
  color = local.compute_color
}

category "ecs_security_group" {
  title = "ECS Security Group"
  icon  = "enhanced_encryption"
  color = local.compute_color
}

category "ecs_disk" {
  title = "ECS Disk"
  href  = "/alicloud_insights.dashboard.ecs_disk_detail?input.disk_arn={{.properties.'ARN' | @uri}}"
  icon  = "hard_drive"
  color = local.storage_color
}

category "ecs_image" {
  title = "ECS Image"
  color = local.compute_color
  icon  = "developer_board"
}

category "ecs_instance" {
  title = "ECS Instance"
  href  = "/alicloud_insights.dashboard.ecs_instance_detail?input.instance_arn={{.properties.'ARN' | @uri}}"
  icon  = "memory"
  color = local.compute_color
}

category "cs_kubernetes_cluster_node" {
  title = "Kubernetes Cluster Node"
  icon  = "device_hub"
  color = local.containers_color
}

category "ecs_key_pair" {
  title = "ECS Key Pair"
  icon  = "vpn_key"
  color = local.compute_color
}

category "ecs_network_interface" {
  title = "ECS Network Interface"
  icon  = "settings_input_antenna"
  color = local.compute_color
}

category "ecs_snapshot" {
  title = "ECS Snapshot"
  icon  = "add_a_photo"
  color = local.storage_color
}