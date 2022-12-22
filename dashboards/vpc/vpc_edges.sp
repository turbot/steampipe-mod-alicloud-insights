
edge "vpc_vswitch_to_vpc_vpc" {
  title = "vpc"

  sql = <<-EOQ
    select
      vswitch_id as from_id,
      vpc_id as to_id
    from
      alicloud_vpc_vswitch
    where
      vswitch_id = any($1);
  EOQ

  param "vpc_vswitch_ids" {}
}
