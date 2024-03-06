mod "alicloud_insights" {
  # Hub metadata
  title         = "Alibaba Cloud Insights"
  description   = "Create dashboards and reports for your Alibaba Cloud resources using Powerpipe and Steampipe."
  color         = "#FF6600"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/alicloud-insights.svg"
  categories    = ["alicloud", "dashboard", "public cloud"]

  opengraph {
    title       = "Powerpipe Mod for Alibaba Cloud Insights"
    description = "Create dashboards and reports for your Alibaba Cloud resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/alicloud-insights-social-graphic.png"
  }

  require {
    plugin "alicloud" {
      min_version = "0.13.0"
    }
  }
}
