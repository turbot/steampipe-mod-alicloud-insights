edge "ecs_auto_provisioning_group_to_ecs_instance" {
  title = "deploys"

  sql = <<-EOQ
    select
      apg.auto_provisioning_group_id as from_id,
      i.arn as to_id
    from
      alicloud_ecs_auto_provisioning_group as apg,
      jsonb_array_elements(apg.instances) as group_instance,
      alicloud_ecs_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4)
    where
      group_instance ->> 'InstanceId' = i.instance_id;
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_autoscaling_group_to_ecs_instance" {
  title = "launches"

  sql = <<-EOQ
    select
      asg.scaling_group_id as from_id,
      i.arn as to_id
    from
      alicloud_ecs_autoscaling_group as asg,
      jsonb_array_elements(asg.scaling_instances) as group_instance,
      alicloud_ecs_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4)
    where
      group_instance ->> 'InstanceId' = i.instance_id;
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_autoscaling_group_to_rds_instance" {
  title = "launches"

  sql = <<-EOQ
    select
      asg.scaling_group_id as from_id,
      rdi.arn as to_id
    from
      alicloud_rds_instance as rdi,
      alicloud_ecs_autoscaling_group as asg,
      jsonb_array_elements_text(asg.db_instance_ids) as id
    where
      asg.scaling_group_id = any($1)
      and rdi.db_instance_id = id;
  EOQ

  param "ecs_autoscaling_group_ids" {}
}

edge "ecs_disk_to_ecs_image" {
  title = "image"

  sql = <<-EOQ
    select
      d.arn as from_id,
      i.arn as to_id
    from
      alicloud_ecs_disk as d,
      alicloud_ecs_image as i
    where
      d.image_id = i.image_id
      and d.region = i.region
      and d.account_id = i.account_id
      and d.arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}

edge "ecs_disk_to_ecs_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
      select
        d.arn as from_id,
        s.arn as to_id
      from
        alicloud_ecs_snapshot s
        join unnest($1::text[]) as a on s.arn = a and s.account_id = split_part(a, ':', 5) and s.region = split_part(a, ':', 4)
        left join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id;
  EOQ

  param "ecs_snapshot_arns" {}
}

edge "ecs_disk_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.arn as from_id,
      k.arn as to_id
    from
      alicloud_ecs_disk as d
      join unnest($1::text[]) as a on d.arn = a and d.account_id = split_part(a, ':', 5) and d.region = split_part(a, ':', 4)
      left join alicloud_kms_key k on d.kms_key_id = k.key_id;
  EOQ

  param "ecs_disk_arns" {}
}

edge "ecs_image_to_ecs_instance" {
  title = "instance"

  sql = <<-EOQ
    select
      im.arn as from_id,
      ins.arn as to_id
    from
      alicloud_ecs_instance as ins
      join alicloud_ecs_image as im
        on ins.image_id = im.image_id
        and ins.region = im.region
        and ins.account_id = im.account_id
    where
      ins.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_ecs_disk" {
  title = "mounts"

  sql = <<-EOQ
    select
      i.arn as from_id,
      d.arn as to_id
    from
      alicloud_ecs_instance i
      join alicloud_ecs_disk as d on i.instance_id = d.instance_id
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_ecs_key_pair" {
  title = "key pair"

  sql = <<-EOQ
    select
      i.arn as from_id,
      k.akas::text as to_id
    from
      alicloud_ecs_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4),
      alicloud_ecs_key_pair as k
    where
      i.key_pair_name is not null;
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_ecs_network_interface" {
  title = "eni"

  sql = <<-EOQ
    select
      arn as from_id,
      i ->> 'NetworkInterfaceId' as to_id
    from
      alicloud_ecs_instance
      join unnest($1::text[]) as a on arn = a and account_id = split_part(a, ':', 5) and region = split_part(a, ':', 4),
      jsonb_array_elements(network_interfaces) as i
    where
      i ->> 'NetworkInterfaceId' is not null;
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_ecs_security_group" {
  title = "security groups"

  sql = <<-EOQ
    select
      coalesce(
        n ->> 'NetworkInterfaceId',
        i.arn
      ) as from_id,
      group_id as to_id
    from
      alicloud_ecs_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4)
      join jsonb_array_elements(network_interfaces) as n on true
      join jsonb_array_elements(security_group_ids) as group_id on true
    where
      i.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_ram_role" {
  title = "runs as"

  sql = <<-EOQ
    select
      i.arn as from_id,
      r.arn as to_id
    from
      alicloud_ecs_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4),
      alicloud_ram_role as r,
      jsonb_array_elements(i.ram_role) as role
    where
      role ->> 'RamRoleName' is not null
      and r.name = role ->> 'RamRoleName';
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_vpc_vswitch" {
  title = "vswitch"

  sql = <<-EOQ
    select
      group_id as from_id,
      s.vswitch_id as to_id
    from
      alicloud_ecs_instance as i
      join unnest($1::text[]) as a on i.arn = a and i.account_id = split_part(a, ':', 5) and i.region = split_part(a, ':', 4)
      join alicloud_vpc_vswitch as s on s.vpc_id = i.vpc_id
      join jsonb_array_elements(security_group_ids) as group_id on true;
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_network_interface_to_vpc_eip" {
  title = "eip"

  sql = <<-EOQ
    select
      i.network_interface_id as from_id,
      e.arn as to_id
    from
      alicloud_vpc_eip as e
      join alicloud_ecs_network_interface as i on e.instance_id = i.instance_id
    where
      i.network_interface_id = any($1);
  EOQ

  param "ecs_network_interface_ids" {}
}

edge "ecs_security_group_to_ecs_instance" {
  title = "instance"

  sql = <<-EOQ
    select
      group_id as from_id,
      i.arn  as to_id
    from
      alicloud_ecs_instance as i,
      jsonb_array_elements_text(security_group_ids) as group_id
    where
      group_id = any($1);
  EOQ

  param "ecs_security_group_ids" {}
}

edge "ecs_security_group_to_ecs_launch_template" {
  title = "launch template"
  sql   = <<-EOQ
    select
      latest_version_details -> 'LaunchTemplateData' ->> 'SecurityGroupId' as from_id,
      launch_template_id as to_id
    from
      alicloud_ecs_launch_template
    where
      latest_version_details -> 'LaunchTemplateData' ->> 'SecurityGroupId' = any($1);
  EOQ
  param "ecs_security_group_ids" {}
}

edge "ecs_launch_template_to_ecs_snapshot" {
  title = "snapshot"
  sql   = <<-EOQ
    select
      launch_template_id as from_id,
      s.arn as to_id
    from
      alicloud_ecs_snapshot as s,
      alicloud_ecs_launch_template as t,
      jsonb_array_elements(t.latest_version_details -> 'LaunchTemplateData' -> 'DataDisks' -> 'DataDisk') as disk_config
    where
      t.launch_template_id = any($1)
      and disk_config ->> 'SnapshotId' is not null
      and disk_config ->> 'SnapshotId' = s.snapshot_id;
  EOQ

  param "launch_template_ids" {}
}

edge "ecs_security_group_to_ecs_network_interface" {
  title = "eni"

  sql = <<-EOQ
    select
      group_id as from_id,
      network_interface_id  as to_id
    from
      alicloud_ecs_network_interface,
      jsonb_array_elements_text(security_group_ids) as group_id
    where
      group_id = any($1);
  EOQ

  param "ecs_security_group_ids" {}
}

edge "ecs_security_group_to_rds_instance" {
  title = "rds instance"

  sql = <<-EOQ
    select
      isg->>'SecurityGroupId' as from_id,
      arn as to_id
    from
      alicloud_rds_instance as i,
      jsonb_array_elements(i.security_group_configuration) as isg
    where
      isg->>'SecurityGroupId' = any($1);
  EOQ

  param "ecs_security_group_ids" {}
}

edge "ecs_snapshot_to_ecs_disk" {
  title = "disk"

  sql = <<-EOQ
      select
        s.arn as from_id,
        d.arn as to_id
      from
        alicloud_ecs_snapshot s
        join unnest($1::text[]) as a on s.arn = a and s.account_id = split_part(a, ':', 5) and s.region = split_part(a, ':', 4)
        join alicloud_ecs_disk as d on s.snapshot_id = d.source_snapshot_id;
  EOQ

  param "ecs_snapshot_arns" {}
}

edge "ecs_snapshot_to_ecs_image" {
  title = "image"

  sql = <<-EOQ
    select
      images.arn as to_id,
      s.arn as from_id
    from
      alicloud_ecs_image as images,
      jsonb_array_elements(images.disk_device_mappings) as ddm,
      alicloud_ecs_snapshot as s
      join unnest($1::text[]) as a on s.arn = a and s.account_id = split_part(a, ':', 5) and s.region = split_part(a, ':', 4)
    where
      ddm ->> 'SnapshotId' = s.snapshot_id;
  EOQ
  param "ecs_snapshot_arns" {}
}

edge "ecs_snapshot_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.arn as from_id,
      k.arn as to_id
    from
      alicloud_ecs_snapshot as s
      join unnest($1::text[]) as a on s.arn = a and s.account_id = split_part(a, ':', 5) and s.region = split_part(a, ':', 4)
      left join alicloud_kms_key k on s.kms_key_id = k.key_id;
  EOQ

  param "ecs_snapshot_arns" {}
}