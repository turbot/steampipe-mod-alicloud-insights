dashboard "ecs_security_group_dashboard" {

  title         = "AliCloud ECS Security Group Dashboard"
  documentation = file("./dashboards/ecs/docs/ecs_security_group_dashboard.md")

  tags = merge(local.ecs_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.ecs_security_group_count
      width = 3
    }

    card {
      query = query.ecs_security_group_unassociated_count
      width = 3
    }

    card {
      query = query.ecs_security_unrestricted_ingress_count
      width = 3
    }

    card {
      query = query.ecs_security_unrestricted_egress_count
      width = 3
    }


  }

  container {

    title = "Assessment"

    chart {
      title = "Association Status"
      type  = "donut"
      width = 3
      query = query.ecs_security_group_unassociated_status

      series "count" {
        point "associated" {
          color = "ok"
        }
        point "unassociated" {
          color = "alert"
        }
      }
    }

    chart {
      title = "With Unrestricted Ingress (Excludes ICMP)"
      type  = "donut"
      width = 3
      query = query.ecs_security_group_by_unrestricted_ingress_status

      series "count" {
        point "restricted" {
          color = "ok"
        }
        point "unrestricted" {
          color = "alert"
        }
      }
    }

    chart {
      title = "With Unrestricted Egress (Excludes ICMP)"
      type  = "donut"
      width = 3
      query = query.ecs_security_group_by_unrestricted_egress_status

      series "count" {
        point "restricted" {
          color = "ok"
        }
        point "unrestricted" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Security Groups by Account"
      query = query.ecs_security_group_by_acount
      type  = "column"
      width = 3
    }

    chart {
      title = "Security Groups by Region"
      query = query.ecs_security_group_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Security Groups by VPC"
      query = query.ecs_security_group_by_vpc
      type  = "column"
      width = 3
    }

    chart {
      title = "Security Groups by Type"
      query = query.ecs_security_group_by_type
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "ecs_security_group_count" {
  sql = <<-EOQ
    select count(*) as "Security Groups" from alicloud_ecs_security_group;
  EOQ
}

query "ecs_security_group_unassociated_count" {
  sql = <<-EOQ
    with associated_sg as (
      select
        group_id
      from
        alicloud_ecs_network_interface,
        jsonb_array_elements_text(security_group_ids) as group_id
    )
    select
      count(*) as value,
      'Unassociated' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      alicloud_ecs_security_group s
      left join associated_sg a on s.security_group_id = a.group_id
    where
      a.group_id is null;
  EOQ
}

query "ecs_security_unrestricted_ingress_count" {
  sql = <<-EOQ
    with ingress_sg as (
      select
        distinct arn
      from
        alicloud_ecs_security_group,
        jsonb_array_elements(permissions) as p
      where
        p ->> 'Policy' = 'Accept' and p ->> 'IpProtocol' <> 'ICMP'
        and p ->> 'Direction' = 'ingress'
        and p ->> 'SourceCidrIp' = '0.0.0.0/0'
        and (
          p ->> 'PortRange' in ('-1/-1', '1/65535')
        )
    )
    select
      'Unrestricted Ingress (Excludes ICMP)' as label,
      count(*) as value,
      case
        when count(*) = 0 then 'ok'
        else 'alert'
      end as type
    from
      ingress_sg
  EOQ
}

query "ecs_security_unrestricted_egress_count" {
  sql = <<-EOQ
    with egress_sg as (
      select
        distinct arn
      from
        alicloud_ecs_security_group,
        jsonb_array_elements(permissions) as p
      where
        p ->> 'Policy' = 'Accept' and p ->> 'IpProtocol' <> 'ICMP'
        and p ->> 'Direction' = 'egress'
        and p ->> 'SourceCidrIp' = '0.0.0.0/0'
        and (
          p ->> 'PortRange' in ('-1/-1', '1/65535')
        )
    )
    select
      'Unrestricted Egress (Excludes ICMP)' as label,
      count(*) as value,
      case
        when count(*) = 0 then 'ok'
        else 'alert'
      end as type
    from
      egress_sg
  EOQ
}

# Assessment Queries

query "ecs_security_group_unassociated_status" {
  sql = <<-EOQ
    with associated_sg as (
      select
        group_id
      from
        alicloud_ecs_network_interface,
        jsonb_array_elements_text(security_group_ids) as group_id
    ),
    sg_list as (
      select
        sg.security_group_id,
        case
          when a.group_id is null then false
          else true
        end as is_associated
      from
        alicloud_ecs_security_group as sg
        left join associated_sg a on sg.security_group_id = a.group_id
    )
    select
      case
        when is_associated then 'associated'
        else 'unassociated'
      end as sg_association_status,
        count(*)
    from
      sg_list
    group by
      is_associated;
  EOQ
}

query "ecs_security_group_by_unrestricted_ingress_status" {
  sql = <<-EOQ
    with ingress_sg as (
      select
        distinct arn
      from
        alicloud_ecs_security_group,
        jsonb_array_elements(permissions) as p
      where
        p ->> 'Policy' = 'Accept' and p ->> 'IpProtocol' <> 'ICMP'
        and p ->> 'Direction' = 'ingress'
        and p ->> 'SourceCidrIp' = '0.0.0.0/0'
        and (
          p ->> 'PortRange' in ('-1/-1', '1/65535')
        )
    )
    select
     case when arn is null then 'restricted' else 'unrestricted' end as status,
     count(*)
    from
      ingress_sg
    group by
      status;
  EOQ
}

query "ecs_security_group_by_unrestricted_egress_status" {
  sql = <<-EOQ
    with eggress_sg as (
      select
        distinct arn
      from
        alicloud_ecs_security_group,
        jsonb_array_elements(permissions) as p
      where
        p ->> 'Policy' = 'Accept' and p ->> 'IpProtocol' <> 'ICMP'
        and p ->> 'Direction' = 'egress'
        and p ->> 'SourceCidrIp' = '0.0.0.0/0'
        and (
          p ->> 'PortRange' in ('-1/-1', '1/65535')
        )
    )
    select
     case when arn is null then 'restricted' else 'unrestricted' end as status,
     count(*)
    from
      eggress_sg
    group by
      status;
  EOQ
}

# Analysis Queries

query "ecs_security_group_by_acount" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(s.*) as "total"
    from
      alicloud_ecs_security_group as s,
      alicloud_account as a
    where
      a.account_id = s.account_id
    group by
      account
    order by
      account;
  EOQ
}

query "ecs_security_group_by_region" {
  sql = <<-EOQ
    select
      region as "Region",
      count(*) as "total"
    from
      alicloud_ecs_security_group
    group by
      region
    order by
      region;
  EOQ
}

query "ecs_security_group_by_vpc" {
  sql = <<-EOQ
    select
      vpc_id as "VPC",
      count(*) as "total"
    from
      alicloud_ecs_security_group
    group by
      vpc_id
    order by
      vpc_id;
  EOQ
}

query "ecs_security_group_by_type" {
  sql = <<-EOQ
    select
      type as "VPC Type",
      count(*) as "total"
    from
      alicloud_ecs_security_group
    group by
      type
    order by
      type;
  EOQ
}
