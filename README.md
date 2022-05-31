# AppConfig with S3 Backup

This terraform module creates a AppConfig hosted profile version and an S3 object with the same content. It is intended for use with [config_o_mat](https://github.com/GoCarrot/config_o_mat). The S3 object will be used as a fallback configuration in the event AWS AppConfig goes down.

## Usage

This is a complete example of a minimal setup. It will create and deploy an appconfig profile with the JSON contet `{"foo": "bar", "baz": "boo"}` and create an s3 object named `demo.json` with the same content.

```hcl
module "config" {
  source = "GoCarrot/appconfig-with-s3-backup/aws"

  application_id           = aws_appconfig_application.appconfig.id
  configuration_profile_id = aws_appconfig_configuration_profile.appconfig.configuration_profile_id
  description              = "Demo"
  content_type             = "application/json"
  config_bucket_id         = aws_s3_bucket.config-backup.id
  backup_key               = "demo.json"

  content = jsonencode({
    foo = "bar"
    baz = "boo"
  })
}

resource "aws_s3_bucket" "config-backup" {
  bucket_prefix = "config-backup-"
}

resource "aws_s3_bucket_versioning" "config-backup" {
  bucket = aws_s3_bucket.config-backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "config-backup" {
  bucket = aws_s3_bucket.config-backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_appconfig_application" "appconfig" {
  name        = "appconfig"
  description = "Appconfig App"
}

resource "aws_appconfig_environment" "appconfig" {
  name           = "appconfig"
  description    = "Appconfig env"
  application_id = aws_appconfig_application.appconfig.id

  tags = {
    Service = "shared-infra"
  }
}

resource "aws_appconfig_configuration_profile" "appconfig" {
  name           = "appconfig"
  description    = "Appconfig profile"
  application_id = aws_appconfig_application.appconfig.id
  location_uri   = "hosted"
}

resource "aws_appconfig_deployment" "deployment" {
  application_id           = aws_appconfig_application.appconfig.id
  environment_id           = aws_appconfig_environment.appconfig.environment_id
  configuration_profile_id = aws_appconfig_configuration_profile.appconfig.configuration_profile_id
  description              = "Appconfig deployment"
  deployment_strategy_id   = "AppConfig.AllAtOnce"
  configuration_version    = module.config.hosted_configuration_version.version_number
}
```

It can be used by config_o_mat with

```yaml
fallback_s3_bucket: ${aws_s3_bucket.config-backup.id}

profiles:
  demo:
    application: appconfig
    environment: appconfig
    profile: appconfig
    s3_fallback: demo.json
```

In the event AWS AppConfig is unavailable, config_o_mat will read `demo.json` from `aws_s3_bucket.config-backup` instead.
