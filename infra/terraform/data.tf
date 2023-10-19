#data "template_file" "mixfast_contrato_template" {
#  template = file("contrato.json")
#
#  vars = {
#    vpc_nlb     = "mixfast-nlb-ebefb32cbfc58f9c.elb.us-east-2.amazonaws.com"
#    vpc_link    = "m2q2fd"
#    port        = 9080
#    auth        = "arn:aws:apigateway:us-east-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-2:022874923015:function:mixfast_lambda_authorizer/invocations"
#    credentials = "arn:aws:iam::022874923015:role/mixfast-lambda-role"
#  }
#}