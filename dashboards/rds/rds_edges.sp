edge "rds_instance_to_vpc_vswitch" {
  title = "vswitch"

  sql = <<-EOQ
    select
      coalesce(
        isg->>'SecurityGroupId',
        i.arn
      ) as from_id,
      i.vswitch_id as to_id
    from
      alicloud_rds_instance as i,
      jsonb_array_elements(coalesce(security_group_configuration, '[{}]')) as isg
    where
      i.arn = any($1);
  EOQ

  param "rds_db_instance_arns" {}
}

edge "rds_db_instance_to_read_only_db_instances" {
  title = "read only db instance"
    sql = <<-EOQ
    select
      original_instance.arn as from_id,
      read_instance.arn as to_id
    from
      alicloud_rds_instance as original_instance,
      jsonb_array_elements(original_instance.readonly_db_instance_ids -> 'ReadOnlyDBInstanceId') as rd,
      alicloud_rds_instance as read_instance
    where
      original_instance.arn = any($1)
      and read_instance.db_instance_id = rd ->> 'DBInstanceId';
  EOQ

  param "rds_db_instance_arns" {}
}

edge "rds_db_instance_to_ecs_security_group" {
  title = "security group"
  sql = <<-EOQ
    select
      i.arn as from_id,
      isg->>'SecurityGroupId' as to_id
    from
      alicloud_rds_instance as i,
      jsonb_array_elements(i.security_group_configuration) as isg,
      alicloud_ecs_security_group as sg
    where
      i.arn = any($1)
      and isg->>'SecurityGroupId' = sg.security_group_id;
  EOQ

  param "rds_db_instance_arns" {}
}

edge "rds_db_instance_to_rds_database" {
  title = "database"
    sql = <<-EOQ
    select
      arn as from_id,
      d.db_name as to_id
    from
      alicloud_rds_instance as i,
      alicloud_rds_database as d
    where
      i.arn = any($1)
      and d.db_instance_id = i.db_instance_id;
  EOQ
  param "rds_db_instance_arns" {}
}

edge "rds_db_instance_to_rds_backup" {
  title = "backup"
    sql = <<-EOQ
    select
      i.arn as from_id,
      b.backup_id as to_id
    from
      alicloud_rds_instance as i,
      alicloud_rds_backup as b
    where
      i.arn = any($1)
      and b.db_instance_id = i.db_instance_id;
  EOQ
  param "rds_db_instance_arns" {}
}