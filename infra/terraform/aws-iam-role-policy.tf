resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "${var.name}_api_gateway_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["apigateway.amazonaws.com"]
      }
    }]
  })

  tags = var.tags
}

data "aws_iam_policy_document" "invocation_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_gateway_lambda_role" {
  name               = "${var.name}_api_gateway_lambda_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "api_gateway_lambda_policy" {
  name   = "default"
  role   = aws_iam_role.api_gateway_lambda_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}