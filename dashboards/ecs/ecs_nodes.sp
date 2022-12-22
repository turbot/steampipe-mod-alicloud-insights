// node "cs_kubernetes_cluster_node" {
//   category = category.cs_kubernetes_cluster_node

//   sql = <<-EOQ
//     select
//       k.node_name as id,
//       k.title as title,
//       jsonb_build_object(
//         'Name', k.node_name,
//         'Instance Id', k.instance_id,
//         'Creation Date', k.creation_time,
//         'Account ID', k.account_id,
//         'State', k.state,
//         'Region', k.region
//       ) as properties
//     from
//       alicloud_cs_kubernetes_cluster_node as k,
//       alicloud_ecs_instance as i
//     where
//       i.arn = any($1)
//       and k.instance_id = i.instance_id;
//   EOQ

//   param "ecs_instance_arns" {}
// }

node "ecs_autoscaling_group" {
  category = category.ecs_autoscaling_group

  sql = <<-EOQ
    select
      asg.scaling_group_id as id,
      asg.title as title,
      jsonb_build_object(
        'Name', asg.name,
        'Instance Id', group_instance ->> 'InstanceId',
        'Creation Date', asg.creation_time,
        'Region', asg.region
      ) as properties
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
      image_id as id,
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
      image_id = any($1);
  EOQ

  param "ecs_image_ids" {}
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
      k.name as id,
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
