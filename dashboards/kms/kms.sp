locals {
  kms_common_tags = {
    service = "AliCloud/KMS"
  }
}


category "kms_key" {
  title = "KMS Key"
  href  = "/alicloud_insights.dashboard.kms_key_detail?input.key_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:key"
  color = local.security_color
}
