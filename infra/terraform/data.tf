data "template_file" "mixfast_contrato_template" {
  template = file("./../../contrato/contrato.json")

  vars = {
    vpc_nlb                = "mixfast-nlb-5e871bfe76b588c6.elb.us-east-1.amazonaws.com"
    vpc_link               = "fegwar"
    port_mixfast           = 9080
    port_mixfast_pagamento = 9081
    port_mixfast_producao  = 9082
    auth_cognito           = "arn:aws:cognito-idp:us-east-1:211125470560:userpool/us-east-1_k8PwIF1zv"
    credentials            = aws_iam_role.api_gateway_lambda_role.arn
  }
}