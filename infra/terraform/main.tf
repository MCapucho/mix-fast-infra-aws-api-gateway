terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_api_gateway_rest_api" "mixfast_api_gateway" {
  name        = "${var.name}-api-gateway"
  description = "API Gateway do Mix Fast"

  tags = var.tags
}

resource "aws_api_gateway_resource" "mixfast_api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mixfast_api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "mixfast_api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.mixfast_api_gateway.id
  resource_id   = aws_api_gateway_resource.mixfast_api_gateway_resource.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "mixfast_api_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mixfast_api_gateway.id
  resource_id             = aws_api_gateway_resource.mixfast_api_gateway_resource.id
  http_method             = aws_api_gateway_method.mixfast_api_gateway_method.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.name}.com/{proxy}"

  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

#resource "aws_api_gateway_domain_name" "mixfast_api_gateway_domain" {
#  domain_name             = "${var.name}.com"
#}
#
#resource "aws_api_gateway_base_path_mapping" "mixfast_api_gateway_base_path_mapping" {
#  api_id      = aws_api_gateway_rest_api.mixfast_api_gateway.id
#  domain_name = aws_api_gateway_domain_name.mixfast_api_gateway_domain.domain_name
#}