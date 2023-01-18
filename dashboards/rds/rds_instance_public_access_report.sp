dashboard "rds_instance_public_access_report" {

  title         = "Alicloud RDS Instance Public Access Report"
  documentation = file("./dashboards/rds/docs/rds_instance_report_public_access.md")

  tags = merge(local.rds_common_tags, {
    type     = "Report"
    category = "Public Access"
  })

  container {

    card {
      query = query.rds_instance_count
      width = 2
    }

    card {
      query = query.rds_instance_public_count
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

    column "DB Instance ID" {
      href = "${dashboard.rds_instance_detail.url_path}?input.db_instance_arn={{.ARN | @uri}}"
    }

    query = query.rds_instance_public_access_table
  }

}

query "rds_instance_public_access_table" {
  sql = <<-EOQ
    select
      i.db_instance_id as "DB Instance ID",
      case
        when i.db_instance_net_type = 'Extranet' then 'Public' else 'Private' end as "Public/Private",
      i.db_instance_status as "Status",
      a.title as "Account",
      i.account_id as "Account ID",
      i.region as "Region",
      i.arn as "ARN"
    from
      alicloud_rds_instance as i,
      alicloud_account as a
    where
      i.account_id = a.account_id
    order by
      i.db_instance_id;
  EOQ
}
