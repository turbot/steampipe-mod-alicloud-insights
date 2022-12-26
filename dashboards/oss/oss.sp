locals {
  oss_common_tags = {
    service = "AliCloud/OSS"
  }
}

category "oss_bucket" {
  title = "OSS Bucket"
  href  = "/alicloud_insights.dashboard.s3_bucket_detail?input.bucket_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons_outline:archive_box"
  color = local.storage_color
}