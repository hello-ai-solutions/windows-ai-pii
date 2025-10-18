resource "aws_api_gateway_rest_api" "pii_api" {
  name = "pii-proxy-api"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ips
          }
        }
      }
    ]
  })
}

resource "aws_api_gateway_resource" "detect_pii" {
  rest_api_id = aws_api_gateway_rest_api.pii_api.id
  parent_id   = aws_api_gateway_rest_api.pii_api.root_resource_id
  path_part   = "detect-pii"
}

resource "aws_api_gateway_method" "post_detect_pii" {
  rest_api_id   = aws_api_gateway_rest_api.pii_api.id
  resource_id   = aws_api_gateway_resource.detect_pii.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.pii_api.id
  resource_id = aws_api_gateway_resource.detect_pii.id
  http_method = aws_api_gateway_method.post_detect_pii.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.pii_proxy.invoke_arn
}

resource "aws_api_gateway_deployment" "pii_api_deployment" {
  depends_on = [
    aws_api_gateway_method.post_detect_pii,
    aws_api_gateway_integration.lambda_integration
  ]
  
  rest_api_id = aws_api_gateway_rest_api.pii_api.id
  stage_name  = "prod"
}
