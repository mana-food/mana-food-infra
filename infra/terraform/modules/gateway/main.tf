resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method

  integration_http_method = "POST"
  type                   = "MOCK"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [aws_api_gateway_integration.this]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "dev"
}
