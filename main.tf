# Create Hosted Zone
resource "aws_route53_zone" "this" {
  count   = var.allow_destroy && local.is_valid_subdomain && local.is_valid_name ? 1 : 0
  name    = "${local.subdomain}.${local.domain}"
  comment = "Managed by Terraform - Private Hosted Zone"

  dynamic "vpc" {
    for_each = var.is_private ? var.vpc_associations : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.region
    }
  }

  tags = merge(var.tags, { "ManagedBy" = "Terraform" })
}

# Create Route53 Records
resource "aws_route53_record" "record" {
  for_each = { for rec in var.records : "${rec.name}-${lookup(rec, "set_identifier", "")}" => rec }
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.alias ? null : each.value.ttl

  # Prevent email-related DNS records
  lifecycle {
    precondition {
      condition     = !contains(["MX", "SPF", "TXT", "DKIM"], each.value.type)
      error_message = "Email-related DNS records (MX, SPF, TXT, DKIM) are not allowed."
    }
  }

  # Prevent confidential information
  lifecycle {
    precondition {
      condition     = !can(regex(".*(secret|password|token|key).*", each.value.name))
      error_message = "Confidential information detected in DNS record name."
    }
  }

  records = each.value.alias ? [] : [each.value.value_or_alias_target]

  set_identifier = each.value.routing_policy == "Weighted" || each.value.routing_policy == "Failover" ? each.value.name : null

  dynamic "weighted_routing_policy" {
    for_each = each.value.routing_policy == "Weighted" ? [each.value] : []
    content {
      weight = each.value.weight
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.routing_policy == "Failover" ? [each.value] : []
    content {
      type = each.value.failover
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.routing_policy == "Latency" ? [each.value] : []
    content {
      region = each.value.region
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.routing_policy == "Geolocation" ? [each.value] : []
    content {
      continent = each.value.continent
    }
  }

  dynamic "alias" {
    for_each = each.value.alias ? [1] : []
    content {
      name                   = each.value.value_or_alias_target
      zone_id                = each.value.alias_zone_id
      evaluate_target_health = true
    }
  }
}

# RDS Endpoint Record
resource "aws_route53_record" "rds_endpoint" {
  zone_id = aws_route53_zone.this[0].zone_id
  name    = "rds.${local.subdomain}.${local.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [var.rds_endpoint]
}

# Additional CNAME Record
resource "aws_route53_record" "custom_cname" {
  zone_id = aws_route53_zone.this[0].zone_id
  name    = "app.${local.subdomain}.${local.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [var.custom_cname_target]
}