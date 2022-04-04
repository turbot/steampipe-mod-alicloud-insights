dashboard "alicloud_ecs_instance_public_access_report" {

  title         = "Alicloud ECS Instance Public Access Report"
  documentation = file("./dashboards/ecs/docs/ecs_instance_report_public_access.md")

  tags = merge(local.ecs_common_tags, {
    type     = "Report"
    category = "Public Access"
  })

  container {

    card {
      query = query.alicloud_ecs_instance_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_instance_public_access_count
      width = 2
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "ARN" {
      display = "none"
    }

    column "Instance ID" {
      href = "${dashboard.alicloud_ecs_instance_detail.url_path}?input.instance_arn={{.ARN | @uri}}"
    }

    query = query.alicloud_ecs_instance_public_access_table
  }

}

query "alicloud_ecs_instance_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      alicloud_ecs_instance
    where
      public_ip_address is not null;
  EOQ
}

query "alicloud_ecs_instance_public_access_table" {
  sql = <<-EOQ
    select
      i.instance_id as "Instance ID",
      i.tags ->> 'Name' as "Name",
      case when public_ip_address is null then 'Private' else 'Public' end as "Public/Private",
      i.public_ip_address as "Public IP Address",
      a.title as "Account",
      i.account_id as "Account ID",
      i.region as "Region",
      i.arn as "ARN"
    from
      alicloud_ecs_instance as i,
      alicloud_account as a
    where
      i.account_id = a.account_id
    order by
      i.instance_id;
  EOQ
}
