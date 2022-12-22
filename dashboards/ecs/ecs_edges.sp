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
    where
      i.arn = any($1)
      and group_instance ->> 'InstanceId' = i.instance_id;
  EOQ

  param "ecs_instance_arns" {}
}

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
    where
      i.arn = any($1)
      and group_instance ->> 'InstanceId' = i.instance_id;
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_image_to_ecs_instance" {
  title = "instance"

  sql = <<-EOQ
    select
      image_id as from_id,
      arn as to_id
    from
      alicloud_ecs_instance as i
    where
      arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_ecs_key_pair" {
  title = "key pair"

  sql = <<-EOQ
    select
      arn as from_id,
      key_pair_name as to_id
    from
      alicloud_ecs_instance as i
    where
      key_pair_name is not null
      and i.arn = any($1);
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
      alicloud_ecs_instance,
      jsonb_array_elements(network_interfaces) as i
    where
      arn = any($1)
      and  i ->> 'NetworkInterfaceId' is not null;
  EOQ

  param "ecs_instance_arns" {}
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
      join jsonb_array_elements(network_interfaces) as n on true
      join jsonb_array_elements(security_group_ids) as group_id on true
    where
      i.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_instance_to_vcs_vswitch" {
  title = "vswitch"

  sql = <<-EOQ
    select
      group_id as from_id,
      s.vswitch_id as to_id
    from
      alicloud_ecs_instance as i
      join alicloud_vpc_vswitch as s on s.vpc_id = i.vpc_id
      join jsonb_array_elements(security_group_ids) as group_id on true
    where
      i.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_disk_to_ecs_image" {
  title = "image"

  sql = <<-EOQ
    select
      d.arn as from_id,
      d.image_id as to_id
    from
      alicloud_ecs_disk as d
    where
      d.arn = any($1);
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
        left join alicloud_ecs_disk as d on s.source_disk_id = d.disk_id
      where
        s.arn = any($1);
  EOQ

    param "ecs_snapshot_arns" {}
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

edge "ecs_snapshot_to_disk" {
  title = "disk"

  sql = <<-EOQ
      select
        s.arn as from_id,
        d.arn as to_id
      from
        alicloud_ecs_snapshot s
        left join alicloud_ecs_disk as d on s.snapshot_id = d.source_snapshot_id
      where
        s.arn = any($1);
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
      left join alicloud_kms_key k on d.kms_key_id = k.key_id
    where
      d.arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}

edge "ecs_instance_to_ecs_disk" {
  title = "disk"

  sql = <<-EOQ
    select
      i.arn as from_id,
      d.arn as to_id
    from
      alicloud_ecs_instance i
      left join alicloud_ecs_disk as d on i.instance_id = d.instance_id
    where
      i.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

edge "ecs_snapshot_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.arn as from_id,
      k.arn as to_id
    from
      alicloud_ecs_snapshot as s
      left join alicloud_kms_key k on s.kms_key_id = k.key_id
    where
      s.arn = any($1);
  EOQ

  param "ecs_snapshot_arns" {}
}