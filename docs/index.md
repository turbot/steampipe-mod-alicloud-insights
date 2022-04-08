---
repository: "https://github.com/turbot/steampipe-mod-alicloud-insights"
---

# Alibaba Cloud Insights Mod

Create dashboards and reports for your Alibaba Cloud resources using Steampipe.

<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ecs_instance_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ecs_snapshot_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_oss_bucket_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ecs_instance_public_access_report.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ram_user_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_kms_key_age_report" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_vpc_dashboard.png" width="50%" type="thumbnail"/>

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- Is encryption enabled and what keys are used for encryption?
- Is versioning enabled?
- What are the relationships between closely connected resources like RAM users, groups, and policies?

Dashboards are available for 6+ services, including ECS, RAM, OSS, VPC, and more!

## References

[Alibaba Cloud](https://alibabacloud.com/) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration, and `dashboards` that organize and display key pieces of information.

## Documentation

- **[Dashboards →](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards)**

## Getting started

### Installation

1) Install the Alibaba Cloud plugin:

```shell
steampipe plugin install alicloud
```

2) Clone this repo:

```sh
git clone https://github.com/turbot/steampipe-mod-alicloud-insights.git
cd steampipe-mod-alicloud-insights
```

### Usage

Start your dashboard server to get started:

```shell
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194.

From here, you can view all of your dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe Alicloud plugin](https://hub.steampipe.io/plugins/turbot/alicloud).

## Get involved

* Contribute: [GitHub Repo](https://github.com/turbot/steampipe-mod-alicloud-insights)
* Community: [Slack Channel](https://steampipe.io/community/join)
