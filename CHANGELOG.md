## v0.9 [2024-05-14]

_Enhancements_

- Queries have been optimized to better work with the connection quals. ([#95](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/95))

## v0.8 [2024-03-06]

_Powerpipe_

[Powerpipe](https://powerpipe.io) is now the preferred way to run this mod!  [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)

All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

_Enhancements_

- Focus documentation on Powerpipe commands.
- Show how to combine Powerpipe mods with Steampipe plugins.

## v0.7 [2023-11-08]

_Breaking changes_

- Updated the plugin dependency section of the mod to use `min_version` instead of `version`. ([#89](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/89))

## v0.6 [2023-08-07]

_Bug fixes_

- Updated the Age Report dashboards to order by the creation time of the resource. ([#83](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/83))
- Fixed dashboard localhost URLs in README and index doc. ([#82](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/82))

## v0.5 [2023-02-03]

_Enhancements_

- Updated the `card` width across all the dashboards to enhance readability. ([#79](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/79))
- Updated `AliCloud VPC Detail` and `AliCloud VPC vSwitch Detail` dashboards to include the relationships the resources share with VPC flow logs. ([#75](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/75))
- Updated `AliCloud RAM Role Detail` and `AliCloud ECS Instance Detail` dashboards to include the relationships the resources share with ECS instances and RAM roles respectively. ([#77](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/77))

## v0.4 [2023-01-20]

_Dependencies_

- Steampipe `v0.18.0` or higher is now required. ([#66](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/66))
- Alibaba Cloud plugin `v0.13.0` or higher is now required. ([#66](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/66))

_What's new?_

- Added resource relationship graphs across all the detail dashboards to highlight the relationship the resource shares with other resources. ([#65](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/65))
- New dashboards added: ([#65](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/65))
  - [AliCloud RDS Instance Dashboard](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.rds_instance_dashboard)
  - [AliCloud RDS Instance Detail](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.rds_instance_detail)
  - [AliCloud RDS Instance Age Report](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.rds_instance_age_report)
  - [AliCloud RDS Instance Public Access Report](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.rds_instance_public_access_report)
  - [AliCloud VPC VSwitch Detail](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.vpc_vswitch_detail)
  - [AliCloud RAM Policy Detail](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.ram_policy_detail)
  - [AliCloud ECS Snapshot Detail](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards/dashboard.ecs_snapshot_detail)

## v0.3 [2023-01-12]

_Bug fixes_

- Fixed invalid input `param` in `alicloud_oss_bucket_detail` dashboard. ([#62](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/62))

## v0.2 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README to the latest format. ([#56](https://github.com/turbot/steampipe-mod-alicloud-insights/pull/56))

## v0.1 [2022-04-11]

_What's new?_

New dashboards, reports, and details for the following services:
- ECS
- KMS
- OSS
- RAM
- VPC
