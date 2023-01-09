# VPC Variables
variable "region" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  description = "AWS Region"
  type        = list(any)
}


variable "vpc-cidr" {
  default     = "10.20.0.0/16"
  description = "VPC CIDR Block"
  type        = string
}

variable "public-subnet-1-cidr" {
  default     = "10.20.0.0/24"
  description = "Public Subnet 1 CIDR Block"
  type        = string
}

variable "public-subnet-2-cidr" {
  default     = "10.20.1.0/24"
  description = "Public Subnet 2 CIDR Block"
  type        = string
}

variable "private-subnet-1-cidr" {
  default     = "10.20.2.0/24"
  description = "Private Subnet 1 CIDR Block"
  type        = string
}

variable "private-subnet-2-cidr" {
  default     = "10.20.3.0/24"
  description = "Private Subnet 2 CIDR Block"
  type        = string
}

variable "private-subnet-3-cidr" {
  default     = "10.20.4.0/24"
  description = "Private Subnet 3 CIDR Block"
  type        = string
}

variable "private-subnet-4-cidr" {
  default     = "10.20.5.0/24"
  description = "Private Subnet 4 CIDR Block"
  type        = string
}

variable "environment_tag" {
  default     = "Altschool holiday challenge"
  description = "Environment tag"
  type        = string
}


variable "ssh-location" {
  default     = "0.0.0.0/0"
  description = "IP Address thst can ssh into EC2 instance"
  type        = string
}


variable "ami" {
  default     = "ami-06878d265978313ca"
  type        = string
  description = "aws ubuntu virtual machine images"
}


variable "ami_linux" {
  default     = "ami-0b5eea76982371e91"
  type        = string
  description = "aws linux virtual machine images"
}


variable "ssl_certificate" {
  default     = "arn:aws:acm:us-east-1:336078645485:certificate/b217008e-31fe-42d5-aa47-eeedca3fcf1f"
  description = "My Domain SSL certificate"
  type        = string
}


variable "zone-id" {
  default     = "Z0250793JO3W7INOVM5H"
  description = "Route 53 Hosted-zone id"
  type        = string

}


variable "domain-name" {
  default     = "altschool.bukolatestimony.me"
  description = "Hosted-zone name"
  type        = string

}



