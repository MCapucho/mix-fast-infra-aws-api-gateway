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
  body        = file("swagger_mixfast.json")

  tags = var.tags
}

resource "aws_api_gateway_deployment" "mixfast_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.mixfast_api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.mixfast_api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "mixfast_api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.mixfast_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.mixfast_api_gateway.id
  stage_name    = "mixfast_dev"
}

resource "aws_lambda_function" "mixfast_lambda_authorizer" {
  function_name    = "${var.name}_lambda_authorizer"
  filename         = "mixfast_lambda.zip"
  source_code_hash = filebase64sha256("mixfast_lambda.zip")
  handler          = "index.handler"
  role             = "arn:aws:iam::022874923015:role/mixfast-lambda-role"
  runtime          = "nodejs18.x"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group]
  }

  tags = var.tags
}

resource "aws_api_gateway_authorizer" "mixfast_api_gateway_authorizer" {
  name                   = "${var.name}_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.mixfast_api_gateway.id
  authorizer_uri         = aws_lambda_function.mixfast_lambda_authorizer.invoke_arn
  authorizer_credentials = "arn:aws:iam::022874923015:role/mixfast-lambda-role"
  type                   = "TOKEN"
}