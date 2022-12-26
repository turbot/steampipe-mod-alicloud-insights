edge "rds_instance_to_vpc_vswitch" {
  title = "vswitch"

  sql = <<-EOQ
    select
      arn as from_id,
      vswitch_id as to_id
    from
      alicloud_rds_instance
    where
      arn = any($1);
  EOQ

param "rds_db_instance_arns" {}
}