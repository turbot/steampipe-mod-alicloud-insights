---
repository: "https://github.com/turbot/steampipe-mod-alicloud-insights"
---

# Alibaba Cloud Insights Mod

Create dashboards and reports for your Alibaba Cloud resources using Steampipe.

<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ecs_instance_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ecs_instance_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_kms_key_age_report.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_kms_key_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_oss_bucket_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_oss_bucket_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_ram_user_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_vpc_detail.png" width="50%" type="thumbnail"/>

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- Is encryption enabled and what keys are used for encryption?
- Is versioning enabled?
- What are the relationships between closely connected resources like RAM users, groups, and policies?

Dashboards are available for ECS, KMS, RAM, RDS, OSS, and VPC services.

## References

[Alibaba Cloud](https://alibabacloud.com/) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration, and `dashboards` that organize and display key pieces of information.

## Documentation

- **[Dashboards →](https://hub.steampipe.io/mods/turbot/alicloud_insights/dashboards)**

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the AliCloud plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install alicloud
```

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-alicloud-insights.git
cd steampipe-mod-alicloud-insights
```

### Usage

Before running any benchmarks, it's recommended to generate your AliCloud credential report:

```sh
aliyun ims GenerateCredentialReport --endpoint ims.aliyuncs.com
```

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194. From here, you can view dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe AliCloud plugin](https://hub.steampipe.io/plugins/turbot/alicloud).

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional compliance controls, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join #steampipe on Slack →](https://turbot.com/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-alicloud-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Alibaba Cloud Insights Mod](https://github.com/turbot/steampipe-mod-alicloud-insights/labels/help%20wanted)
