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