---
repository: "https://github.com/turbot/steampipe-mod-alicloud-insights"
---

# Alibaba Cloud Insights Mod

Create dashboards and reports for your Alibaba Cloud resources using Steampipe.

<!-- TO DO -->

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- Is encryption enabled and what keys are used for encryption?
- Is versioning enabled?
- What are the relationships between closely connected resources like RAM users, groups, and policies?

<!-- TO DO -->

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
