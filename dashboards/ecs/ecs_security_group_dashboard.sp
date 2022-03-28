dashboard "alicloud_ecs_security_group_dashboard" {

  title         = "Alibaba Cloud ECS Security Group Dashboard"
  documentation = file("./dashboards/ecs/docs/ecs_security_group_dashboard.md")

  tags = merge(local.ecs_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      sql   = query.alicloud_ecs_security_group_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_ecs_security_group_unassociated_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_ecs_security_unrestricted_ingress_rdp_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_ecs_security_unrestricted_ingress_ssh_count.sql
      width = 2
    }

    card {
      sql   = query.alicloud_ecs_security_unrestricted_ingress_remote_count.sql
      width = 2
    }

  }

  container {

    title = "Assessment"

    chart {
      title = "Association Status"
      type  = "donut"
      width = 3
      sql   = query.alicloud_ecs_security_group_unassociated_status.sql

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
      title = "With Unrestricted Ingress RDP"
      type  = "donut"
      width = 3
      sql   = query.alicloud_ecs_security_group_by_unrestricted_ingress_rdp_status.sql

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
      title = "With Unrestricted Egress SSH"
      type  = "donut"
      width = 3
      sql   = query.alicloud_ecs_security_group_by_unrestricted_ingress_ssh_status.sql

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
      title = "With Unrestricted Egress Remote"
      type  = "donut"
      width = 3
      sql   = query.alicloud_ecs_security_group_by_unrestricted_ingress_remote_status.sql

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
      sql   = query.alicloud_ecs_security_group_by_acount.sql
      type  = "column"
      width = 4
    }

    chart {
      title = "Security Groups by Region"
      sql   = query.alicloud_ecs_security_group_by_region.sql
      type  = "column"
      width = 4
    }

    chart {
      title = "Security Groups by VPC"
      sql   = query.alicloud_ecs_security_group_by_vpc.sql
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

query "alicloud_ecs_security_unrestricted_ingress_rdp_count" {
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
          p ->> 'PortRange' in ('-1/-1', '3389/3389')
          or (3389 between split_part(p ->> 'PortRange', '/', 1) :: int and split_part(p ->> 'PortRange', '/', 2) :: int)
        )
    )
    select
      'Unrestricted Ingress RDP' as label,
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

query "alicloud_ecs_security_unrestricted_ingress_ssh_count" {
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
          p ->> 'PortRange' in ('-1/-1', '22/22')
          or (22 between split_part(p ->> 'PortRange', '/', 1) :: int and split_part(p ->> 'PortRange', '/', 2) :: int)
        )
    )
    select
      'Unrestricted Ingress SSH' as label,
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

query "alicloud_ecs_security_group_by_unrestricted_ingress_rdp_status" {
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
          p ->> 'PortRange' in ('-1/-1', '3389/3389')
          or (3389 between split_part(p ->> 'PortRange', '/', 1) :: int and split_part(p ->> 'PortRange', '/', 2) :: int)
        )
    )
    select
     case when b.arn is null then 'restricted' else 'unrestricted' end as status,
     count(*)
    from
      alicloud_ecs_security_group as sg left join bad_groups as b on sg.arn = b.arn
    group by
      status;
  EOQ
}

query "alicloud_ecs_security_group_by_unrestricted_ingress_ssh_status" {
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
          p ->> 'PortRange' in ('-1/-1', '22/22')
          or (22 between split_part(p ->> 'PortRange', '/', 1) :: int and split_part(p ->> 'PortRange', '/', 2) :: int)
        )
    )
    select
      case when b.arn is null then 'restricted' else 'unrestricted' end as status,
      count(*)
    from
      alicloud_ecs_security_group as sg left join bad_groups as b on sg.arn = b.arn
    group by
      status;
  EOQ
}

query "alicloud_ecs_security_group_by_unrestricted_ingress_remote_status" {
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
      case when b.arn is null then 'restricted' else 'unrestricted' end as status,
      count(*)
    from
      alicloud_ecs_security_group as sg left join bad_groups as b on sg.arn = b.arn
    group by
      status;
  EOQ
}

# Analysis Queries

query "alicloud_ecs_security_group_by_acount" {
  sql = <<-EOQ
    select
      a.title as "account",
      count(s.*) as "security_groups"
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
      count(*) as "security_groups"
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
      count(*) as "security_groups"
    from
      alicloud_ecs_security_group
    group by
      vpc_id
    order by
      vpc_id;
  EOQ
}
