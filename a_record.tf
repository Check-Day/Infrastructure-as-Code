# Run these after load balancer is created through kubectl
# Update name servers from Route 53 in Godaddy or any other service where domain is bought

resource "aws_route53_zone" "checkday_url" {
  name = var.domainUrl
}

resource "aws_route53_record" "checkday_new_a_record" {
  zone_id = aws_route53_zone.checkday_url.zone_id
  name    = var.applicationDesiredUrl
  type    = "A"

  alias {
    name                   = var.dnsName
    zone_id                = var.canonicalHostedZoneId
    evaluate_target_health = true
  }
}

variable "domainUrl" {
  type        = string
  description = "Describes app port"
  default     = "checkday.online"
}

variable "applicationDesiredUrl" {
  type        = string
  description = "Describes app port"
  default     = "checkday.online"
}

variable "dnsName" {
  type        = string
  description = "Describes app port"
  default     = "a46c8eff24d084754baa93c96c6d2d87-366027846.us-east-1.elb.amazonaws.com"
}

variable "canonicalHostedZoneId" {
  type        = string
  description = "Describes app port"
  default     = "Z35SXDOTRQ7X7K"
}