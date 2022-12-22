locals {
  ecs_common_tags = {
    service = "AliCloud/ECS"
  }
}

category "ecs_auto_provisioning_group" {
  title = "ECS Autoprovisioning Group"
  icon  = "text:APG"
  color = local.compute_color
}

category "ecs_autoscaling_group" {
  title = "ECS Autoscaling Group"
  icon  = "library-add"
  color = local.compute_color
}

category "ecs_security_group" {
  title = "ECS Security Group"
  icon  = "enhanced-encryption"
  color = local.compute_color
}

category "ecs_disk" {
  title = "ECS Disk"
  href  = "/alicloud_insights.dashboard.ecs_disk_detail?input.disk_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:inbox-stack"
  color = local.storage_color
}

category "ecs_image" {
  title = "ECS Image"
  color = local.compute_color
  icon  = "developer-board"
}

category "ecs_instance" {
  title = "ECS Instance"
  href  = "/alicloud_insights.dashboard.ecs_instance_detail?input.instance_arn={{.properties.'ARN' | @uri}}"
  icon  = "dns"
  color = local.compute_color
}

category "cs_kubernetes_cluster_node" {
  title = "Kubernetes Cluster Node"
  icon  = "device-hub"
  color = local.containers_color
}

category "ecs_key_pair" {
  title = "ECS Key Pair"
  icon  = "vpn-key"
  color = local.compute_color
}

category "ecs_network_interface" {
  title = "ECS Network Interface"
  icon  = "memory"
  color = local.compute_color
}

category "ecs_snapshot" {
  title = "ECS Snapshot"
  icon  = "heroicons-outline:viewfinder-circle"
  color = local.storage_color
}