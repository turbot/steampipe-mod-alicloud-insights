locals {
  rds_common_tags = {
    service = "Alicloud/RDS"
  }
}

category "rds_instance" {
  title = "RDS Instance"
  color = local.database_color
  href  = "/alicloud_insights.dashboard.rds_instance_detail?input.db_instance_arn={{.properties.ARN | @uri}}"
  icon  = "database"
}
