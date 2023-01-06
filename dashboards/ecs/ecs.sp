locals {
  ecs_common_tags = {
    service = "AliCloud/ECS"
  }
}

category "ecs_auto_provisioning_group" {
  title = "ECS Autoprovisioning Group"
  color = local.compute_color
  icon  = "rocket_launch"
}

category "ecs_autoscaling_group" {
  title = "ECS Autoscaling Group"
  color = local.compute_color
  icon  = "library_add"
}

category "ecs_launch_template" {
  title = "ECS Launch Template"
  color = local.compute_color
  icon  = "text:LT"
}

category "ecs_security_group" {
  title = "ECS Security Group"
  color = local.compute_color
  icon  = "enhanced_encryption"
}

category "ecs_disk" {
  title = "ECS Disk"
  color = local.storage_color
  href  = "/alicloud_insights.dashboard.ecs_disk_detail?input.disk_arn={{.properties.'ARN' | @uri}}"
  icon  = "hard_drive"
}

category "ecs_image" {
  title = "ECS Image"
  color = local.compute_color
  icon  = "developer_board"
}

category "ecs_instance" {
  title = "ECS Instance"
  color = local.compute_color
  href  = "/alicloud_insights.dashboard.ecs_instance_detail?input.instance_arn={{.properties.'ARN' | @uri}}"
  icon  = "memory"
}

category "cs_kubernetes_cluster_node" {
  title = "Kubernetes Cluster Node"
  color = local.containers_color
  icon  = "device_hub"
}

category "ecs_key_pair" {
  title = "ECS Key Pair"
  color = local.compute_color
  icon  = "vpn_key"
}

category "ecs_network_interface" {
  title = "ECS Network Interface"
  color = local.compute_color
  icon  = "settings_input_antenna"
}

category "ecs_snapshot" {
  title = "ECS Snapshot"
  color = local.storage_color
  icon  = "add_a_photo"
}