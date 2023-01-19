node "ecs_auto_provisioning_group" {
  category = category.ecs_auto_provisioning_group

  sql = <<-EOQ
    select
      apg.auto_provisioning_group_id as id,
      apg.title as title,
      jsonb_build_object(
        'Name', apg.name,
        'Instance Id', ins_detail ->> 'InstanceId',
        'Creation Date', apg.creation_time,
        'Region', apg.region
      ) as properties
    from
      alicloud_ecs_auto_provisioning_group as apg,
      jsonb_array_elements(apg.instances) as ins_detail,
      alicloud_ecs_instance as i
    where
      i.arn = any($1)
      and ins_detail ->> 'InstanceId' = i.instance_id;
  EOQ

  param "ecs_instance_arns" {}
}

node "ecs_autoscaling_group" {
  category = category.ecs_autoscaling_group

  sql = <<-EOQ
    select
      scaling_group_id as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'Creation Date', creation_time,
        'Region', region
      ) as properties
    from
      alicloud_ecs_autoscaling_group as asg
    where
      scaling_group_id = any($1);
  EOQ

  param "ecs_autoscaling_group_ids" {}
}

node "ecs_disk" {
  category = category.ecs_disk

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ID', disk_id,
        'ARN', arn,
        'Size', size,
        'Account ID', account_id,
        'Region', region,
        'KMS Key ID', kms_key_id
      ) as properties
    from
      alicloud_ecs_disk
    where
      arn = any($1);
  EOQ

  param "ecs_disk_arns" {}
}

node "ecs_image" {
  category = category.ecs_image

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'Image ID', image_id,
        'Image Family', image_family,
        'Status', status,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_image
    where
      arn = any($1);
  EOQ

  param "ecs_image_arns" {}
}

node "ecs_instance" {
  category = category.ecs_instance

  sql = <<-EOQ
    select
      arn as id,
      title,
      jsonb_build_object(
        'Instance ID', instance_id,
        'Name', name,
        'ARN', arn,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_instance
    where
      arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

node "ecs_key_pair" {
  category = category.ecs_key_pair

  sql = <<-EOQ
    select
      k.akas::text as id,
      k.title as title,
      jsonb_build_object(
        'Name', k.name,
        'Creation Date', k.creation_time,
        'Region', k.region,
        'Fingerprint', k.key_pair_finger_print
      ) as properties
    from
      alicloud_ecs_instance as i,
      alicloud_ecs_key_pair as k
    where
      i.key_pair_name = k.name
      and i.account_id = k.account_id
      and i.region = k.region
      and i.arn = any($1);
  EOQ

  param "ecs_instance_arns" {}
}

node "ecs_launch_template" {
  category = category.ecs_launch_template

  sql = <<-EOQ
    select
      launch_template_id as id,
      title as title,
      jsonb_build_object(
        'Template Id', launch_template_id,
        'Creation Time', create_time,
        'Creator', created_by,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_launch_template
    where
      launch_template_id = any($1);
  EOQ

  param "launch_template_ids" {}
}

node "ecs_network_interface" {
  category = category.ecs_network_interface

  sql = <<-EOQ
    select
      network_interface_id as id,
      title as title,
      jsonb_build_object(
        'ID', network_interface_id,
        'Interface Type', type,
        'Status', status,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_network_interface
    where
      network_interface_id = any($1 ::text[]);
  EOQ

  param "ecs_network_interface_ids" {}
}

node "ecs_security_group" {
  category = category.ecs_security_group

  sql = <<-EOQ
    select
      security_group_id as id,
      title as title,
      jsonb_build_object(
        'Group ID', security_group_id,
        'Description', description,
        'ARN', arn,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_security_group
    where
      security_group_id = any($1);
  EOQ

  param "ecs_security_group_ids" {}
}

node "ecs_snapshot" {
  category = category.ecs_snapshot

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'ID', snapshot_id,
        'ARN', arn,
        'Account ID', account_id,
        'Region', region
      ) as properties
    from
      alicloud_ecs_snapshot
    where
      arn = any($1);
  EOQ

  param "ecs_snapshot_arns" {}
}
