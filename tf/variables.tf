variable "app-s3-bucket-name" {
  description = "APP Bucket name where We store the images"
  type        = string
  default     = "app-jrr"
}

variable "s3-addon-version" {
  description = "S3 addon version that We want to install"
  type        = string
  default     = "v1.14.1-eksbuild.1"
}

variable "app-name" {
  description = "APP name"
  type        = string
  default     = "app-jrr"
}

variable "github-repo" {
  description = "GitHub Repo"
  type        = string
  default     = "https://github.com/mandevnull/app-jrr"
}

variable "github-token" {
  description = "GitHub token for changing APP deploy tag"
  type        = string
  default     = "PUT HERE YOUR GITHUB TOKEN"
}

