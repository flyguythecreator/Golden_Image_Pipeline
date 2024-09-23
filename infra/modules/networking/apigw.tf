resource "aws_apigatewayv2_domain_name" "example" {
  domain_name = "http-api.example.com"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.example.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "example" {
  name    = aws_apigatewayv2_domain_name.example.domain_name
  type    = "A"
  zone_id = aws_route53_zone.example.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "example" {
  api_id           = aws_apigatewayv2_api.example.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.example.invoke_arn
  identity_sources = ["route.request.header.Auth"]
  name             = "example-authorizer"
}

resource "aws_apigatewayv2_deployment" "example" {
  api_id      = aws_apigatewayv2_api.example.id
  description = "Example deployment"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_vpc_link" "example" {
  name               = "example"
  security_group_ids = [data.aws_security_group.example.id]
  subnet_ids         = data.aws_subnets.example.ids

  tags = {
    Usage = "example"
  }
}

resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.example.id
  credentials_arn  = aws_iam_role.example.arn
  description      = "Example with a load balancer"
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.example.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.example.id

  tls_config {
    server_name_to_verify = "example.com"
  }

  request_parameters = {
    "append:header.authforintegration" = "$context.authorizer.authorizerResponse"
    "overwrite:path"                   = "staticValueForIntegration"
  }

  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }

  response_parameters {
    status_code = 200
    mappings = {
      "overwrite:statuscode" = "204"
    }
  }
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "ANY /example/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_apigatewayv2_stage" "example" {
  api_id = aws_apigatewayv2_api.example.id
  name   = "example-stage"
}