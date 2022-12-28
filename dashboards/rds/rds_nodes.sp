node "rds_instance" {
  category = category.rds_instance

  sql = <<-EOQ
    select
      arn as id,
      title,
      jsonb_build_object(
        'ARN', arn,
        'Status', db_instance_status,
        'IP Type', ip_type,
        'Instance Memory', db_instance_memory,
        'Create Time', creation_time,
        'DB Instance Class', db_instance_class,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_rds_instance
    where
      arn = any($1);
  EOQ

  param "rds_db_instance_arns" {}
}

node "rds_database" {
  category = category.rds_database

  sql = <<-EOQ
    select
      db_name as id,
      title,
      jsonb_build_object(
        'Name',db_name,
        'DB Instance ID',db_instance_id,
        'Status', db_status,
        'Engine',engine,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_rds_database
    where
      db_name = any($1);
  EOQ

  param "rds_database_names" {}
}


node "rds_backup" {
  category = category.rds_backup

  sql = <<-EOQ
    select
      backup_id as id,
      title,
      jsonb_build_object(
        'Backup Start Time',backup_start_time,
        'DB Instance ID',db_instance_id,
        'Status', backup_status,
        'Backup Method', backup_method,
        'Backup Location', backup_location,
        'Backup Mode',backup_mode,
        'Backup End Time',backup_end_time,
        'Account ID', account_id
      ) as properties
    from
      alicloud_rds_backup
    where
      backup_id = any($1);
  EOQ

  param "rds_database_backup_ids" {}
}