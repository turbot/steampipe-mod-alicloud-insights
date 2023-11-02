mod "alicloud_insights" {
  # hub metadata
  title         = "Alibaba Cloud Insights"
  description   = "Create dashboards and reports for your Alibaba Cloud resources using Steampipe."
  color         = "#FF6600"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/alicloud-insights.svg"
  categories    = ["alicloud", "dashboard", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for Alibaba Cloud Insights"
    description = "Create dashboards and reports for your Alibaba Cloud resources using Steampipe."
    image       = "/images/mods/turbot/alicloud-insights-social-graphic.png"
  }

  require {
    plugin "alicloud" {
      min_version = "0.13.0"
    }
  }
}
