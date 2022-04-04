dashboard "alicloud_ecs_security_group_dashboard" {

  title         = "Alicloud ECS Security Group Dashboard"
  documentation = file("./dashboards/ecs/docs/ecs_security_group_dashboard.md")

  tags = merge(local.ecs_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.alicloud_ecs_security_group_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_security_group_unassociated_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_security_unrestricted_ingress_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_security_unrestricted_egress_count
      width = 2
    }

    card {
      query = query.alicloud_ecs_security_unrestricted_ingress_remote_count
      width = 2
    }

  }

  container {

    title = "Assessment"

    chart {
      title = "Association Status"
      type  = "donut"
      width = 3
      query = query.alicloud_ecs_security_group_unassociated_status

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
      query = query.alicloud_ecs_security_group_by_unrestricted_ingress_status

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
      query = query.alicloud_ecs_security_group_by_unrestricted_egress_status

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
      query = query.alicloud_ecs_security_group_by_acount
      type  = "column"
      width = 4
    }

    chart {
      title = "Security Groups by Region"
      query = query.alicloud_ecs_security_group_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "Security Groups by VPC"
      query = query.alicloud_ecs_security_group_by_vpc
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "alicloud_ecs_security_group_count" {
  sql = <<-EOQ
    select count(*) as "Security Groups" from alicloud_ecs_security_group;
  EOQ
}

query "alicloud_ecs_security_group_unassociated_count" {
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

query "alicloud_ecs_security_unrestricted_ingress_count" {
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

query "alicloud_ecs_security_unrestricted_egress_count" {
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

query "alicloud_ecs_security_unrestricted_ingress_remote_count" {
  sql = <<-EOQ
    with bad_groups as (
      select
        distinct arn
      from
        alicloud_ecs_security_group,
        jsonb_array_elements(permissions) as p
      where
        p ->> 'Policy' = 'Accept'
        and p ->> 'Direction' = 'ingress'
        and p ->> 'SourceCidrIp' = '0.0.0.0/0'
        and (
          p ->> 'PortRange' in ('-1/-1', '22/22', '3389/3389')
          or (
            3389 between split_part(p ->> 'PortRange', '/', 1) :: int and split_part(p ->> 'PortRange', '/', 2) :: int
            or 22 between split_part(p ->> 'PortRange', '/', 1) :: int and split_part(p ->> 'PortRange', '/', 2) :: int
          )
        )
    )
    select
      'Unrestricted Ingress Remote' as label,
      count(*) as value,
      case
        when count(*) = 0 then 'ok'
        else 'alert'
      end as type
    from
      alicloud_ecs_security_group as a
      left join bad_groups as b on a.arn = b.arn
    where
      b.arn is not null;
  EOQ
}

# Assessment Queries

query "alicloud_ecs_security_group_unassociated_status" {
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

query "alicloud_ecs_security_group_by_unrestricted_ingress_status" {
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

query "alicloud_ecs_security_group_by_unrestricted_egress_status" {
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

query "alicloud_ecs_security_group_by_acount" {
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

query "alicloud_ecs_security_group_by_region" {
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

query "alicloud_ecs_security_group_by_vpc" {
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
