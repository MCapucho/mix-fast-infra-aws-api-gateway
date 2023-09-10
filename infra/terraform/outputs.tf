output "api_gateway_arn" {
  value = aws_api_gateway_rest_api.mixfast_api_gateway.arn
}

output "teste" {
  value = aws_lambda_function.mixfast_lambda_authorizer.invoke_arn
}