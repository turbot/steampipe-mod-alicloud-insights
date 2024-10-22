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
      alicloud_rds_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4),
      jsonb_array_elements(coalesce(security_group_configuration, '[{}]')) as isg;
  EOQ

  param "rds_instance_arns" {}
}

edge "rds_instance_to_read_only_db_instances" {
  title = "read only db instance"
  sql   = <<-EOQ
    select
      original_instance.arn as from_id,
      read_instance.arn as to_id
    from
      alicloud_rds_instance as original_instance
      join unnest($1::text[]) as a on original_instance.arn = a and original_instance.account_id = split_part(a, ':', 5) and original_instance.region = split_part(a, ':', 4),
      jsonb_array_elements(original_instance.readonly_db_instance_ids -> 'ReadOnlyDBInstanceId') as rd,
      alicloud_rds_instance as read_instance
    where
      read_instance.db_instance_id = rd ->> 'DBInstanceId';
  EOQ

  param "rds_instance_arns" {}
}

edge "rds_instance_to_ecs_security_group" {
  title = "security group"
  sql   = <<-EOQ
    select
      i.arn as from_id,
      isg->>'SecurityGroupId' as to_id
    from
      alicloud_rds_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4),
      jsonb_array_elements(i.security_group_configuration) as isg,
      alicloud_ecs_security_group as sg
    where
      isg->>'SecurityGroupId' = sg.security_group_id;
  EOQ

  param "rds_instance_arns" {}
}

edge "rds_instance_to_rds_database" {
  title = "database"
  sql   = <<-EOQ
    select
      arn as from_id,
      d.db_name as to_id
    from
      alicloud_rds_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4),
      alicloud_rds_database as d
    where
      d.db_instance_id = i.db_instance_id;
  EOQ
  param "rds_instance_arns" {}
}

edge "rds_instance_to_rds_backup" {
  title = "backup"
  sql   = <<-EOQ
    select
      i.arn as from_id,
      b.backup_id as to_id
    from
      alicloud_rds_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4),
      alicloud_rds_backup as b
    where
      b.db_instance_id = i.db_instance_id;
  EOQ
  param "rds_instance_arns" {}
}