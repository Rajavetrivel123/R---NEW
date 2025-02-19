output "hosted_zone_id" {
  description = "The ID of the created hosted zone"
  value       = aws_route53_zone.this[0].id
}

output "hosted_zone_arn" {
  description = "The ARN of the created hosted zone"
  value       = aws_route53_zone.this[0].arn
}

output "record_names" {
  description = "List of created record names"
  value       = [for rec in var.records : rec.name]
}