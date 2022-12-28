locals {
  kms_common_tags = {
    service = "AliCloud/KMS"
  }
}


category "kms_key" {
  title = "KMS Key"
  href  = "/alicloud_insights.dashboard.kms_key_detail?input.key_arn={{.properties.'ARN' | @uri}}"
  icon  = "key"
  color = local.security_color
}


category "kms_secret" {
  title = "KMS Secret"
  icon  = "heroicons_outline:key"
  color = local.security_color
}