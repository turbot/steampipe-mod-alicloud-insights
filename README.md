# Alibaba Cloud Insights

An Alibaba Cloud dashboarding tool that can be used to view dashboards and reports across all of your Alibaba Cloud accounts.

![image](https://raw.githubusercontent.com/turbot/steampipe-mod-alicloud-insights/main/docs/images/alicloud_oss_bucket_dashboard.png)

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- Is encryption enabled and what keys are used for encryption?
- Is versioning enabled?
- What are the relationships between closely connected resources like RAM users, groups, and policies?

Dashboards are available for ECS, KMS, RAM, OSS, and VPC services.

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

By default, the dashboard interface will then be launched in a new browser
window at https://localhost:9194. From here, you can run benchmarks by
selecting one or searching for a specific one.

### Credentials

This mod uses the credentials configured in the [Steampipe AliCloud plugin](https://hub.steampipe.io/plugins/turbot/alicloud).

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional compliance controls, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-alicloud-compliance/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Alibaba Cloud Insights Mod](https://github.com/turbot/steampipe-mod-alicloud-insights/labels/help%20wanted)
