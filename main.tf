locals {
  tags           = var.tags
  backup_content = coalesce(var.backup_content, var.content)
}

resource "aws_appconfig_hosted_configuration_version" "appconfig" {
  application_id           = var.application_id
  configuration_profile_id = var.configuration_profile_id
  description              = var.description
  content_type             = var.content_type

  content = var.content

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_object" "s3" {
  bucket       = var.config_bucket_id
  key          = var.backup_key
  content_type = var.content_type

  content = local.backup_content
  tags    = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
