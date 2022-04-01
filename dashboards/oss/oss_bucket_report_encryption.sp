dashboard "alicloud_oss_bucket_encryption_report" {

  title = "Alicloud OSS Bucket Encryption Report"
  documentation = file("./dashboards/oss/docs/oss_bucket_report_encryption.md")

  tags = merge(local.oss_common_tags, {
    type     = "Report"
    category = "Encryption"
  })

  container {

    card {
      query = query.alicloud_oss_bucket_count
      width = 2
    }

    card {
      query = query.alicloud_oss_bucket_encrypted_with_byok_count
      width = 2
    }

    card {
      query = query.alicloud_oss_bucket_encrypted_with_servcie_key_count
      width = 2
    }

    card {
      query = query.alicloud_oss_bucket_unencrypted_count
      width = 2
    }

    card {
      query = query.alicloud_oss_bucket_ssl_not_enforced_count
      width = 2
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "ARN" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.alicloud_oss_bucket_detail.url_path}?input.bucket_arn={{.ARN | @uri}}"
    }

    query = query.alicloud_oss_bucket_encryption_table
  }

}

query "alicloud_oss_bucket_encrypted_with_byok_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Encrypted With BYOK' as label
    from
      alicloud_oss_bucket b
      left join alicloud_kms_key k on b.server_side_encryption ->> 'KMSMasterKeyID' = k.key_id
    where
      server_side_encryption ->> 'SSEAlgorithm' = 'KMS' and k.creator = k.account_id;
  EOQ
}

query "alicloud_oss_bucket_encrypted_with_servcie_key_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Encrypted With Service Key' as label
    from
      alicloud_oss_bucket b
      left join alicloud_kms_key k on b.server_side_encryption ->> 'KMSMasterKeyID' = k.key_id
    where
      server_side_encryption ->> 'SSEAlgorithm' = 'KMS' and k.creator = 'Oss';
  EOQ
}

query "alicloud_oss_bucket_encryption_table" {
  sql = <<-EOQ
    with ssl_ok as (
      select
        distinct name,
        arn,
        'ok' as status
      from
        alicloud_oss_bucket,
        jsonb_array_elements(policy -> 'Statement') as s,
        jsonb_array_elements_text(s -> 'Principal') as p,
        jsonb_array_elements_text(s -> 'Resource') as r,
        jsonb_array_elements_text(
          s -> 'Condition' -> 'Bool' -> 'acs:SecureTransport'
        ) as ssl
      where
        p = '*'
        and s ->> 'Effect' = 'Deny'
        and ssl :: bool = false
    )
    select
      b.name as "Name",
      case when ssl.status = 'ok' then 'Enabled' else null end as "HTTPS Enforced",
      case when b.server_side_encryption ->> 'SSEAlgorithm' <> '' then 'Enabled' else null end as "Default Encryption",
      b.server_side_encryption ->> 'SSEAlgorithm' as "SSE Algorithm",
      k.key_id as "KMS Key ID",
      k.creator as "Creator",
      a.title as "Account",
      b.account_id as "Account ID",
      b.region as "Region",
      b.arn as "ARN"
    from
      alicloud_oss_bucket as b
      left join alicloud_kms_key k on b.server_side_encryption ->> 'KMSMasterKeyID' = k.key_id
      left join ssl_ok as ssl on b.arn = ssl.arn
      left join alicloud_account as a on b.account_id = a.account_id
    order by
      b.name;
  EOQ
}
