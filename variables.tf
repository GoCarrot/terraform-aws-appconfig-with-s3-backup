variable "application_id" {
  type        = string
  description = "The AWS AppConfig Application ID"
}

variable "configuration_profile_id" {
  type        = string
  description = "The AWS AppConfig Configuration Profile ID"
}

variable "description" {
  type        = string
  description = "The description to give to the hosted configuration version."
}

variable "content_type" {
  type        = string
  description = "The content_type of the content stored in AWS AppConfig and S3"

  validation {
    condition     = contains(["application/json", "application/x-yaml", "text/plain"], var.content_type)
    error_message = "The content_type must be one of application/json, application/x-yaml, or text/plain."
  }
}

variable "content" {
  type        = string
  description = "The configuration content for AWS AppConfig, and for S3 unless var.backup_content is specified."
}

variable "config_bucket_id" {
  type        = string
  description = "The ID of the S3 bucket to store backup configuration in."
}

variable "backup_key" {
  type        = string
  description = "The key of the S3 bucket to store backup configuration in."
}

variable "backup_content" {
  type        = string
  default     = null
  description = "Override for backup content. If not specified the content in the S3 bucket will be the same as the content in the AppConfig hosted configuration version."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to attach to the S3 object. Intended for ABAC."
}
