
edge "ram_role_to_ram_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      arn as from_id,
      policy_arn ->> 'PolicyName' as to_id
    from
      alicloud_ram_role,
      jsonb_array_elements(attached_policy) as policy_arn
    where
      arn = any($1);
  EOQ

  param "ram_role_arns" {}
}
