locals {
  oss_common_tags = {
    service = "AliCloud/OSS"
  }
}

category "oss_bucket" {
  title = "OSS Bucket"
  href  = "/alicloud_insights.dashboard.oss_bucket_detail?input.bucket_arn={{.properties.'ARN' | @uri}}"
  icon  = "cleaning_bucket"
  color = local.storage_color
}