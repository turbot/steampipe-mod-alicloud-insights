dashboard "ecs_security_group_detail" {

  title         = "AliCloud ECS Security Group Detail"
  documentation = file("./dashboards/ecs/docs/ecs_security_group_detail.md")

  tags = merge(local.ecs_common_tags, {
    type = "Detail"
  })

  input "security_group_id" {
    title = "Select a security group:"
    query = query.ecs_security_group_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.ecs_security_group_unassociated
      args = {
        id = self.input.security_group_id.value
      }
    }

    card {
      width = 2
      query = query.ecs_security_unrestricted_ingress
      args = {
        id = self.input.security_group_id.value
      }
    }

    card {
      width = 2
      query = query.ecs_security_unrestricted_egress
      args = {
        id = self.input.security_group_id.value
      }
    }

  }

  container {

    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.ecs_security_group_overview
        args = {
          id = self.input.security_group_id.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.ecs_security_group_tags
        args = {
          id = self.input.security_group_id.value
        }
      }
    }
    container {
      width = 6

      table {
        title = "Associated to"
        query = query.ecs_security_group_associated
        args = {
          id = self.input.security_group_id.value
        }

        column "ARN" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.ecs_instance_detail.url_path}?input.instance_arn={{.ARN | @uri}}"
        }
      }
    }

  }

  container {

    width = 6

    flow {
      base  = flow.security_group_rules_sankey
      title = "Ingress Analysis"
      query = query.ecs_security_group_ingress_rule_sankey
      args = {
        id = self.input.security_group_id.value
      }
    }

    table {
      title = "Ingress Rules"
      query = query.ecs_security_group_ingress_rules
      args = {
        id = self.input.security_group_id.value
      }
    }

  }

  container {

    width = 6

    flow {
      base  = flow.security_group_rules_sankey
      title = "Egress Analysis"
      query = query.ecs_security_group_egress_rule_sankey
      args = {
        id = self.input.security_group_id.value
      }
    }

    table {
      title = "Egress Rules"
      query = query.ecs_security_group_egress_rules
      args = {
        id = self.input.security_group_id.value
      }
    }

  }

}

flow "security_group_rules_sankey" {
  type = "sankey"

  category "alert" {
    color = "alert"
  }

  category "ok" {
    color = "ok"
  }

}

query "ecs_security_group_input" {
  sql = <<-EOQ
    select
      title as label,
      security_group_id as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'security_group_id', security_group_id
      ) as tags
    from
      alicloud_ecs_security_group
    order by
      title;
  EOQ
}

query "ecs_security_group_unassociated" {
  sql = <<-EOQ
    with associated_sg as (
      select
        distinct group_id
      from
        alicloud_ecs_network_interface,
        jsonb_array_elements_text(security_group_ids) as group_id
      where
        group_id = $1
    )
    select
      case when a.group_id is null then 'Unassociated' else 'Associated' end as value,
      'Network Interface' as label,
      case when a.group_id is null then 'alert' else 'ok' end as type
    from
      alicloud_ecs_security_group s
      left join associated_sg a on s.security_group_id = a.group_id
    where
      s.security_group_id = $1;
  EOQ

  param "id" {}

}

query "ecs_security_unrestricted_ingress" {
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
        and security_group_id = $1
    )
    select
      'Ingress (Excludes ICMP)' as label,
      case when count(*) = 0 then 'Restricted' else 'Unrestricted' end as value,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      ingress_sg
  EOQ

  param "id" {}

}

query "ecs_security_unrestricted_egress" {
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
        and security_group_id = $1
    )
    select
      'Egress (Excludes ICMP)' as label,
      case when count(*) = 0 then 'Restricted' else 'Unrestricted' end as value,
      case when count(*) = 0 then 'ok' else 'alert' end as type
    from
      egress_sg
  EOQ

  param "id" {}
}

query "ecs_security_group_overview" {
  sql = <<-EOQ
    select
      name as "Group Name",
      security_group_id as "Group ID",
      description as "Description",
      vpc_id as "VPC ID",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      alicloud_ecs_security_group
    where
      security_group_id = $1;
  EOQ

  param "id" {}
}

query "ecs_security_group_tags" {
  sql = <<-EOQ
    select
      tag ->> 'TagKey' as "Key",
      tag ->> 'TagValue' as "Value"
    from
      alicloud_ecs_security_group,
      jsonb_array_elements(tags_src) as tag
    where
      security_group_id = $1
    order by
      tag ->> 'TagKey';
    EOQ

  param "id" {}
}

query "ecs_security_group_associated" {
  sql = <<-EOQ
    select
      name as "Name",
      instance_id as "Instance ID",
      status as "Status",
      instance_type as "Instance Type",
      arn as "ARN"
    from
      alicloud_ecs_instance,
      jsonb_array_elements_text(security_group_ids) as sg
    where
      sg = $1;
  EOQ

  param "id" {}
}

query "ecs_security_group_ingress_rules" {
  sql = <<-EOQ
    select
      concat(text(p ->> 'SourceCidrIp'), text(p ->> 'Ipv6SourceCidrIp'), text(p ->> 'SourceGroupId'),text(p ->> 'SourcePrefixListId')) as "Source",
      p ->> 'Policy' as "Policy",
      case
        when p ->> 'IpProtocol' = 'ALL' then 'All Traffic'
        when p ->> 'IpProtocol' = 'ICMP' then 'ICMP'
        else p ->> 'IpProtocol'
      end as "Protocol",
      case
        when p ->> 'PortRange' = '-1/-1' or p ->> 'PortRange' = '1/65535' then 'All'
        when SPLIT_PART(p ->> 'PortRange','/',2) = SPLIT_PART(p ->> 'PortRange','/',1) then SPLIT_PART(p ->> 'PortRange','/',2)::text
        else p ->> 'PortRange'
      end as "Ports"
    from
      alicloud_ecs_security_group,
      jsonb_array_elements(permissions) as p
    where
      p ->> 'Direction' = 'ingress'
      and security_group_id = $1;
  EOQ

  param "id" {}
}

query "ecs_security_group_egress_rules" {
  sql = <<-EOQ
    select
      concat(text(p ->> 'DestCidrIp'), text(p ->> 'Ipv6DestCidrIp'), text(p ->> 'DestGroupId'),text(p ->> 'DestPrefixListId')) as "Destination",
      p ->> 'Policy' as "Policy",
      case
        when p ->> 'IpProtocol' = 'ALL' then 'All Traffic'
        when p ->> 'IpProtocol' = 'ICMP' then 'ICMP'
        else p ->> 'IpProtocol'
      end as "Protocol",
      case
        when p ->> 'PortRange' = '-1/-1' or p ->> 'PortRange' = '1/65535' then 'All'
        when SPLIT_PART(p ->> 'PortRange','/',2) = SPLIT_PART(p ->> 'PortRange','/',1) then SPLIT_PART(p ->> 'PortRange','/',2)::text
        else p ->> 'PortRange'
      end as "Ports"
    from
      alicloud_ecs_security_group,
      jsonb_array_elements(permissions) as p
    where
      p ->> 'Direction' = 'egress'
      and security_group_id = $1;
  EOQ

  param "id" {}
}

query "ecs_security_group_ingress_rule_sankey" {
  sql = <<-EOQ
   with associations as (
    select
      title,
      arn,
      sg as security_group_id
    from
      alicloud_ecs_instance,
      jsonb_array_elements_text(security_group_ids) as sg
    where
      sg = $1
    ),
    rules as (
       select
          concat(text(p ->> 'SourceCidrIp'), text(p ->> 'Ipv6SourceCidrIp'), text(p ->> 'SourceGroupId'),text(p ->> 'SourcePrefixListId')) as "source",
          case
            when p ->> 'IpProtocol' = 'ALL' then 'All Traffic'
            when p ->> 'IpProtocol' = 'ICMP' then 'All ICMP'
            when p ->> 'PortRange' = '-1/-1' or p ->> 'PortRange' = '1/65535' then concat('All ',p ->> 'IpProtocol')
            when SPLIT_PART(p ->> 'PortRange','/',2) = SPLIT_PART(p ->> 'PortRange','/',1)
              then concat(SPLIT_PART(p ->> 'PortRange','/',2),'/',p ->> 'IpProtocol')
            else concat(
              SPLIT_PART(p ->> 'PortRange','/',1),
              '-',
              SPLIT_PART(p ->> 'PortRange','/',2),
              '/',
              p ->> 'IpProtocol'
            )
          end as port_proto,
          case
            when ( text(p ->> 'SourceCidrIp') = '0.0.0.0/0' or text(p ->> 'Ipv6SourceCidrIp') = '::/0')
                and p ->> 'IpProtocol' <> 'ICMP'
                and (
                  p ->> 'PortRange' = '-1/-1'
                  or p ->> 'PortRange' = '1/65535'
                ) then 'alert'
            else 'ok'
          end as category,
          security_group_id
        from
          alicloud_ecs_security_group,
          jsonb_array_elements(permissions) as p
        where
        security_group_id = $1
        and p ->> 'Direction' = 'ingress'
    )

    -- Nodes  ---------
      select
        distinct concat('src_',source) as id,
        source as title,
        0 as depth,
        'source' as category,
        null as from_id,
        null as to_id
      from
        rules
      union
      select
        distinct port_proto as id,
        port_proto as title,
        1 as depth,
        'port_proto' as category,
        null as from_id,
        null as to_id
      from
        rules
      union
      select
        distinct sg.security_group_id as id,
        name as title,
        2 as depth,
        'security_group' as category,
        null as from_id,
        null as to_id
      from
        alicloud_ecs_security_group sg
        inner join rules sgr on sg.security_group_id = sgr.security_group_id
      union
      select
          distinct arn as id,
          title as title,
          3 as depth,
          title,
          security_group_id as from_id,
          null as to_id
        from
          associations
      -- Edges  ---------
      union select
        null as id,
        null as title,
        null as depth,
        category,
        concat('src_',source) as from_id,
        port_proto as to_id
      from
        rules
      union select
        null as id,
        null as title,
        null as depth,
        category,
        port_proto as from_id,
        security_group_id as to_id
      from
        rules
  EOQ

  param "id" {}
}

query "ecs_security_group_egress_rule_sankey" {
  sql = <<-EOQ
   with associations as (
    select
      title,
      arn,
      sg as security_group_id
    from
      alicloud_ecs_instance,
      jsonb_array_elements_text(security_group_ids) as sg
    where
      sg = $1
    ),
    rules as (
       select
          concat(text(p ->> 'DestCidrIp'), text(p ->> 'Ipv6DestCidrIp'), text(p ->> 'DestGroupId'),text(p ->> 'DestPrefixListId')) as "source",
          case
            when p ->> 'IpProtocol' = 'ALL' then 'All Traffic'
            when p ->> 'IpProtocol' = 'ICMP' then 'All ICMP'
            when p ->> 'PortRange' = '-1/-1' or p ->> 'PortRange' = '1/65535' then concat('All ',p ->> 'IpProtocol')
            when SPLIT_PART(p ->> 'PortRange','/',2) = SPLIT_PART(p ->> 'PortRange','/',1)
              then concat(SPLIT_PART(p ->> 'PortRange','/',2),'/',p ->> 'IpProtocol')
            else concat(
              SPLIT_PART(p ->> 'PortRange','/',1),
              '-',
              SPLIT_PART(p ->> 'PortRange','/',2),
              '/',
              p ->> 'IpProtocol'
            )
          end as port_proto,
          case
            when ( text(p ->> 'DestCidrIp') = '0.0.0.0/0' or text(p ->> 'Ipv6DestCidrIp') = '::/0')
                and p ->> 'IpProtocol' <> 'ICMP'
                and (
                  p ->> 'PortRange' = '-1/-1'
                  or p ->> 'PortRange' = '1/65535'
                ) then 'alert'
            else 'ok'
          end as category,
          security_group_id
        from
          alicloud_ecs_security_group,
          jsonb_array_elements(permissions) as p
        where
        security_group_id = $1
        and p ->> 'Direction' = 'egress'
    )

    -- Nodes  ---------
      select
        distinct concat('src_',source) as id,
        source as title,
        3 as depth,
        'source' as category,
        null as from_id,
        null as to_id
      from
        rules
      union
      select
        distinct port_proto as id,
        port_proto as title,
        2 as depth,
        'port_proto' as category,
        null as from_id,
        null as to_id
      from
        rules
      union
      select
        distinct sg.security_group_id as id,
        name as title,
        1 as depth,
        'security_group' as category,
        null as from_id,
        null as to_id
      from
        alicloud_ecs_security_group sg
        inner join rules sgr on sg.security_group_id = sgr.security_group_id
      union
      select
          distinct arn as id,
          title as title,
          0 as depth,
          title,
          security_group_id as from_id,
          null as to_id
        from
          associations
      -- Edges  ---------
      union select
        null as id,
        null as title,
        null as depth,
        category,
        concat('src_',source) as from_id,
        port_proto as to_id
      from
        rules
      union select
        null as id,
        null as title,
        null as depth,
        category,
        port_proto as from_id,
        security_group_id as to_id
      from
        rules
  EOQ

  param "id" {}
}
