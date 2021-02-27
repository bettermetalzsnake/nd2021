variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  type = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "scalenum" {
  type = number
  description = "How many VMs would you like to deploy"
}

variable "username" {
  type = string 
  description = "the username for the VM"
}

variable "password" {
  type = string
  description = "The password for the VM"
}