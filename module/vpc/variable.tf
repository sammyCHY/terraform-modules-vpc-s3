variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}
variable "public_subnets" {
  type        = list(string)
  description = "CIDR block for the public subnet"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR block for the Private subnet"
}

 variable "availability_zones" {
    description  = "Availability zone for the subnets"
    type   = list(string)
 }