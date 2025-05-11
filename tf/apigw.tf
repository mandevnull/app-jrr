# APIGW - We should apply this after istio installation

# Discover NLB created by istio
data "aws_lb" "istio_nlb_jrr" {
  tags = {
    "kubernetes.io/service-name" = "istio-system/istio-ingressgateway"
  }
}

data "aws_lb_listener" "istio_listener_jrr" {
  load_balancer_arn = data.aws_lb.istio_nlb_jrr.arn
  port              = 80
}

# VPC Link
resource "aws_api_gateway_vpc_link" "vpc_link_jrr" {
  name        = "vpc-link-jrr"
  target_arns = [data.aws_lb.istio_nlb_jrr.arn]
}

# APIGW REST API
resource "aws_api_gateway_rest_api" "rest_api_jrr" {
  name        = "apigw-rest-jrr"
  description = "REST API para Istio"

  tags = {
    Name = "apigw-rest-jrr"
  }
}

# APIGW ROUTES
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_jrr.id
  parent_id   = aws_api_gateway_rest_api.rest_api_jrr.root_resource_id
  path_part   = "app-jrr"
}

# APIGW METHOD
resource "aws_api_gateway_method" "default_method_jrr" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_jrr.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "ANY"
  authorization = "NONE"
}

# APIGW INTEGRATION
resource "aws_api_gateway_integration" "default_integration_jrr" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_jrr.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.default_method_jrr.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://app-jrr.test.com" # ISTIO VS
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link_jrr.id
}

# APIGW STAGE
resource "aws_api_gateway_deployment" "rest_api_deployment_jrr" {
  depends_on = [
    aws_api_gateway_integration.default_integration_jrr,
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api_jrr.id
  stage_name  = "prod"
}

