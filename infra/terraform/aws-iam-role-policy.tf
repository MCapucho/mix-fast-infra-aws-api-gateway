data "aws_iam_policy_document" "api_gateway_cloudwatch_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name               = "${var.name}_api_gateway_cloudwatch_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_cloudwatch_role.json
}

data "aws_iam_policy_document" "api_gateway_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_role_policy" {
  name   = "${var.name}_api_gateway_cloudwatch_role_policy"
  role   = aws_iam_role.api_gateway_cloudwatch_role.id
  policy = data.aws_iam_policy_document.api_gateway_cloudwatch_policy.json
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

resource "aws_iam_role_policy" "api_gateway_lambda_role_policy" {
  name   = "${var.name}_api_gateway_lambda_policy"
  role   = aws_iam_role.api_gateway_lambda_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}