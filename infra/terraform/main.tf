resource "aws_api_gateway_rest_api" "mixfast_api_gateway" {
  name        = "${var.name}_api_gateway"
  description = "API Gateway do Mix Fast"
  body        = data.template_file.mixfast_contrato_template.rendered

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_resource" "mixfast_api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mixfast_api_gateway.root_resource_id
  path_part   = "{proxy}"

}

resource "aws_api_gateway_authorizer" "mixfast_api_gateway_authorizer" {
  name                   = "${var.name}_authorizer_proxy"
  rest_api_id            = aws_api_gateway_rest_api.mixfast_api_gateway.id
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:022874923015:function:mixfast_lambda_authorizer/invocations"
  authorizer_credentials = aws_iam_role.api_gateway_lambda_role.arn
  type                   = "TOKEN"
}

resource "aws_api_gateway_method" "mixfast_api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.mixfast_api_gateway.id
  resource_id   = aws_api_gateway_resource.mixfast_api_gateway_resource.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mixfast_api_gateway_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "mixfast_api_gateway_integration_vpc_link" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id
  resource_id = aws_api_gateway_resource.mixfast_api_gateway_resource.id
  http_method = aws_api_gateway_method.mixfast_api_gateway_method.http_method

  type                    = "HTTP_PROXY"
  uri                     = "http://mixfast-nlb-aa37518e8412fa4f.elb.us-east-1.amazonaws.com:9080/{id}"
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"

  connection_type = "VPC_LINK"
  connection_id   = "1twc76"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method_response" "mixfast_api_gateway_method_response" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id
  resource_id = aws_api_gateway_resource.mixfast_api_gateway_resource.id
  http_method = aws_api_gateway_method.mixfast_api_gateway_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "mixfast_api_gateway_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id
  resource_id = aws_api_gateway_resource.mixfast_api_gateway_resource.id
  http_method = aws_api_gateway_method.mixfast_api_gateway_method.http_method
  status_code = aws_api_gateway_method_response.mixfast_api_gateway_method_response.status_code
}

resource "aws_api_gateway_deployment" "mixfast_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.mixfast_api_gateway_resource.id,
      aws_api_gateway_method.mixfast_api_gateway_method.id,
      aws_api_gateway_integration.mixfast_api_gateway_integration_vpc_link.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "mixfast_api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.mixfast_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.mixfast_api_gateway.id
  stage_name    = var.name
}

resource "aws_api_gateway_account" "mixfast_api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}

resource "aws_api_gateway_method_settings" "mixfast_api_gateway_settings" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id
  stage_name  = aws_api_gateway_stage.mixfast_api_gateway_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }

  depends_on = [
    aws_api_gateway_stage.mixfast_api_gateway_stage,
    aws_api_gateway_account.mixfast_api_gateway_account
  ]
}