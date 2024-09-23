variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}


variable "image" {
  description = "ASG Server Image"
  default     = "Ubuntu 22.04 64bit"
}


variable "hostname" {
  description = "Hostname for the server"
  default     = "terra-demo"
}