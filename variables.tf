### Project ###
variable "project_name" {
    default = {}
}
variable "environment" {
    type = string
    default = "dev"
}
variable "common_tags" {
    type = map
}
### VPC ###
variable "vpc_cidr" {
    type =  string
    default = "10.0.0.0/16"
}
variable "vpc_tags" {
    default = {}
}
variable "dns-hostname" {
    type = bool
    default = true
}
###Internet Gateway ###
variable "ig_tags" {
    default = {}
}
### Public Subnet  ###
variable "public_subnet_cidrs" {
  type = list 
  validation {
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "Please provide 2 valid public subnet CIDR"
  }
}

variable "public_subnet_cidrs_tags" {
  default = {}
}

### Private Subnet  ###
variable "private_subnet_cidrs" {
  type = list 
  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "Please provide 2 valid private subnet CIDR"
  }
}

variable "private_subnet_cidrs_tags" {
  default = {}
}
### Database Subnet  ###
variable "Database_subnet_cidrs" {
  type = list 
  validation {
    condition = length(var.Database_subnet_cidrs) == 2
    error_message = "Please provide 2 valid Database subnet CIDR"
  }
}
###Database subnet cidrs ###
variable "Database_subnet_cidrs_tags" {
  default = {}
}
###Database subnet groups ###
variable "Database_subnet_group_tags"{
    default = {}
###natgateway  ###
}
variable "nat_gatewat_tags" {
  default = {}
}
###public route table ###
variable "public_route_table_tags" {
    default = {}
###private route table ###
}
variable "private_route_table_tags" {
    default = {}
###database route table ### 
}
variable "Database_route_table_tags" {
    default = {}
###peering ###
}
variable "is_peering_required" {
 default = false
}
variable "acceptor_vpc_id" {
  default = ""
}
variable "vpc_peering_tags" {
  default = {}
}