output "hosted_configuration_version" {
  value = aws_appconfig_hosted_configuration_version.appconfig
}

output "s3_object" {
  value = aws_s3_object.s3
}
