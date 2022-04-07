dashboard "alicloud_vpc_dashboard" {

  title         = "AliCloud VPC Dashboard"
  documentation = file("./dashboards/vpc/docs/vpc_dashboard.md")

  tags = merge(local.vpc_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.alicloud_vpc_count
      width = 2
    }

    card {
      query = query.alicloud_vpc_default_count
      width = 2
    }

    card {
      query = query.alicloud_vpc_no_vswitch_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Default VPCs"
      type  = "donut"
      width = 3
      query = query.alicloud_vpc_default_status

      series "count" {
        point "non-default" {
          color = "ok"
        }
        point "default" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Empty VPCs (No vSwitches)"
      type  = "donut"
      width = 3
      query = query.alicloud_vpc_empty_status

      series "count" {
        point "non-empty" {
          color = "ok"
        }
        point "empty" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "VPCs by Account"
      query = query.alicloud_vpc_by_account
      type  = "column"
      width = 3
    }

    chart {
      title = "VPCs by Region"
      query = query.alicloud_vpc_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "VPCs by Size"
      query = query.alicloud_vpc_by_size
      type  = "column"
      width = 3
    }

    chart {
      title = "VPCs by RFC1918 Range"
      query = query.alicloud_vpc_by_rfc1918_range
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "alicloud_vpc_count" {
  sql = <<-EOQ
    select count(*) as "VPCs" from alicloud_vpc;
  EOQ
}

query "alicloud_vpc_default_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Default VPCs' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      alicloud_vpc
    where
      is_default;
  EOQ
}

query "alicloud_vpc_no_vswitch_count" {
  sql = <<-EOQ
    select
       count(*) as value,
       'VPCs Without vSwitches' as label,
       case when count(*) = 0 then 'ok' else 'alert' end as type
      from
        alicloud_vpc as vpc
        left join alicloud_vpc_vswitch as s on vpc.vpc_id = s.vpc_id
      where
        s.vswitch_id is null;
  EOQ
}

# Assessment Queries

query "alicloud_vpc_default_status" {
  sql = <<-EOQ
    select
      case
        when is_default then 'default'
        else 'non-default'
      end as default_status,
      count(*)
    from
      alicloud_vpc
    group by
      is_default;
  EOQ
}

query "alicloud_vpc_empty_status" {
  sql = <<-EOQ
    with by_empty as (
      select
        distinct vpc.vpc_id,
        case when s.vswitch_id is null then 'empty' else 'non-empty' end as status
      from
        alicloud_vpc as vpc
        left join alicloud_vpc_vswitch as s on vpc.vpc_id = s.vpc_id
    )
    select
      status,
      count(*)
    from
      by_empty
    group by
      status;
  EOQ
}

# Analysis Queries

query "alicloud_vpc_by_account" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(v.*) as "vpcs"
    from
      alicloud_vpc as v,
      alicloud_account as a
    where
      a.account_id = v.account_id
    group by
      account
    order by
      account;
  EOQ
}

query "alicloud_vpc_by_region" {
  sql = <<-EOQ
    select
      region as "Region",
      count(*) as "VPCs"
    from
      alicloud_vpc
    group by
      region
    order by
      region;
  EOQ
}

query "alicloud_vpc_by_size" {
  sql = <<-EOQ
    with vpc_size as (
      select
        vpc_id,
        cidr_block,
        concat(
          '/', masklen(cidr_block),
          ' (', power(2, 32 - masklen(cidr_block :: cidr)), ')'
        ) as size
      from
        alicloud_vpc
    )
    select
      size,
      count(*)
    from
      vpc_size
    group by
      size;
  EOQ
}

query "alicloud_vpc_by_rfc1918_range" {
  sql = <<-EOQ
    with cidr_buckets as (
      select
        vpc_id,
        title,
        cidr_block as cidr,
        case
          when cidr_block <<= '10.0.0.0/8'::cidr then '10.0.0.0/8'
          when cidr_block <<= '172.16.0.0/12'::cidr then '172.16.0.0/12'
          when cidr_block <<= '192.168.0.0/16'::cidr then '192.168.0.0/16'
          else 'Public Range'
        end as rfc1918_bucket
      from
        alicloud_vpc
      union
      select
        vpc_id,
        title,
        b::cidr as cidr,
        case
          when b::cidr <<= '10.0.0.0/8'::cidr then '10.0.0.0/8'
          when b::cidr <<= '172.16.0.0/12'::cidr then '172.16.0.0/12'
          when b::cidr <<= '192.168.0.0/16'::cidr then '192.168.0.0/16'
          else 'Public Range'
        end as rfc1918_bucket
      from
        alicloud_vpc,
        jsonb_array_elements_text(secondary_cidr_blocks) as b
    )
    select
      rfc1918_bucket,
      count(*)
    from
      cidr_buckets
    group by
      rfc1918_bucket
    order by
      rfc1918_bucket
  EOQ
}
