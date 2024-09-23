resource "aws_route53_record" "example_base_url" {
  name    = aws_apigatewayv2_domain_name.example.domain_name
  type    = "A"
  zone_id = aws_route53_zone.example.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "example_multi_url" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = dvo.domain_name == "example.org" ? data.aws_route53_zone.example_org.zone_id : data.aws_route53_zone.example_com.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
# resource "aws_route53_zone" "primary" {
#   name = "example.com"
# }

resource "aws_route53_zone" "private" {
  name = "example.com"
# NOTE: The aws_route53_zone vpc argument accepts multiple configuration
#       blocks. The below usage of the single vpc configuration, the
#       lifecycle configuration, and the aws_route53_zone_association
#       resource is for illustrative purposes (e.g., for a separate
#       cross-account authorization process, which is not shown here).
  vpc {
    vpc_id = aws_vpc.example.id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_zone_association" "secondary" {
  zone_id = aws_route53_zone.example.zone_id
  vpc_id  = aws_vpc.secondary.id
}

resource "aws_route53_health_check" "example" {
  failure_threshold = "5"
  fqdn              = "example.com"
  port              = 443
  request_interval  = "30"
  resource_path     = "/"
  search_string     = "example"
  type              = "HTTPS_STR_MATCH"
}



resource "aws_route53_health_check" "foo" {
  type                            = "CLOUDWATCH_METRIC"
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.foobar.alarm_name
  cloudwatch_alarm_region         = "us-west-2"
  insufficient_data_health_status = "Healthy"
}