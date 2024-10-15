locals {
  kms_common_tags = {
    service = "AliCloud/KMS"
  }
}


category "kms_key" {
  title = "KMS Key"
  color = local.security_color
  href  = "/alicloud_insights.dashboard.kms_key_detail?input.key_arn={{.properties.'ARN' | @uri}}"
  icon  = "key"
}


category "kms_secret" {
  title = "KMS Secret"
  color = local.security_color
  icon  = "key"
}