data "template_file" "mixfast_contrato_template" {
  template = file("./../../contrato/contrato.json")

  vars = {
    vpc_nlb                = "mixfast-nlb-ad1e0c8436c96791.elb.us-east-1.amazonaws.com"
    vpc_link               = "gglmop"
    port_mixfast           = 9080
    port_mixfast_pagamento = 9081
    port_mixfast_producao  = 9082
    auth_cognito           = "arn:aws:cognito-idp:us-east-1:022874923015:userpool/us-east-1_yB6Whcc2z"
    credentials            = aws_iam_role.api_gateway_lambda_role.arn
  }
}