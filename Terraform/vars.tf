variable "prefix" {
  type = string
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  type = string
  description = "The Azure Region in which all resources in this example should be created."
  default = "westus2"
}

variable "scalenum" {
  type = number
  description = "How many VMs would you like to deploy (default is 2)"
  default = 2
}

variable "username" {
  type = string 
  description = "the username for the VM"
}

variable "password" {
  type = string
  description = "The password for the VM"
}


variable "owner" {
  type = string
  description = "the name of the person who owns the resource"
  default = "Marc"
}

locals {
  common_tags = {
    Environment = "Production"
    CreatedBy = "Terraform"
    ProjectName = var.prefix
  }

}  
