# modules/s3/variables.tf
     variable "bucket_name" {
     description  = "Name of the s3 bucket"
     type    = string

}

variable "versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow destroying a non-empty bucket"
  type        = bool
  default     = false
}

variable "acl" {
  description = "ACL for the S3 bucket"
  type        = string
  default     = "private"
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {
    Environment = "dev"
    Terraform   = "true"
  }
}