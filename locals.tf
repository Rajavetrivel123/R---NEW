locals {
  # Validate and extract domain components
  domain_parts = regex("^([a-zA-Z0-9-_]+)\\.(aws-mani\\.nonprod\\.com)$", var.hosted_zone_name)
  subdomain    = local.domain_parts[0]
  domain       = local.domain_parts[1]

  # Subdomain constraints
  is_valid_subdomain = length(local.subdomain) > 0 && length(local.subdomain) <= 63

  # Restricted words
  restricted_words = ["admin", "test", "demo", "internal"]
  is_valid_name    = alltrue([for word in local.restricted_words : !contains(local.subdomain, word)])

   selected_records = {
    Simple   = [for r in var.records : r if var.routing_policy == "Simple"]
    Weighted = [for r in var.records : r if var.routing_policy == "Weighted" && r.weight != null]
    Failover = [for r in var.records : r if var.routing_policy == "Failover" && r.failover != null]
    IP-Based = [for r in var.records : r if var.routing_policy == "IP-Based" && r.ip_address != null]
  }


}