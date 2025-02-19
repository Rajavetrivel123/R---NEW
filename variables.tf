variable "hosted_zone_name" {
  description = "The name of the private hosted zone"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "allow_destroy" {
  description = "Allow Terraform to destroy the hosted zone"
  type        = bool
}

variable "is_private" {
  description = "Determines if the hosted zone is private"
  type        = bool
}

variable "vpc_associations" {
  description = "List of VPCs to associate with the private hosted zone"
  type        = list(object({
    vpc_id = string
    region = string
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "routing_policy" {
  description = "Routing policy type (Simple, Weighted, Failover, IP-Based)"
  type        = string
  validation {
    condition     = contains(["Simple", "Weighted", "Failover", "IP-Based"], var.routing_policy)
    error_message = "Valid values: Simple, Weighted, Failover, IP-Based."
  }
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name                  = string
    type                  = string
    ttl                   = optional(number)
    alias                 = bool
    value_or_alias_target = string
    alias_zone_id         = optional(string)
    routing_policy        = string
    weight                = optional(number)
    failover              = optional(string)
    region                = optional(string)
    continent             = optional(string)
  }))
}

# variable "records" {
#   description = "List of records with different routing policies"
#   type = list(object({
#     name                  = string
#     type                  = string
#     ttl                   = optional(number)
#     alias                 = optional(bool)
#     value_or_alias_target = string
#     weight                = optional(number) # Only needed for Weighted routing
#     health_check_id       = optional(string) 
#     failover              = optional(string) # Only needed for Failover routing
#     ip_address            = optional(string) # Only needed for IP-based routing
#     evaluate_health       = optional(bool)
#     routing_policy        = string # "Simple", "Weighted", "Failover", "IP-Based"
#   }))
# }

variable "rds_endpoint" {
  description = "RDS database endpoint"
  type        = string
}

variable "custom_cname_target" {
  description = "Custom CNAME target"
  type        = string
}
