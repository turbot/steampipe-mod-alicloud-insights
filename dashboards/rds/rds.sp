locals {
  rds_common_tags = {
    service = "AliCloud/RDS"
  }
}

category "rds_instance" {
  title = "RDS Instance"
  color = local.database_color
  href  = "/alicloud_insights.dashboard.rds_instance_detail?input.db_instance_arn={{.properties.ARN | @uri}}"
  icon  = "database"
}

category "rds_database" {
  title = "RDS Database"
  color = local.database_color
  icon  = "text:DB"
}
category "rds_backup" {
  title = "RDS Backup"
  color = local.database_color
  icon  = "settings_backup_restore"
}
