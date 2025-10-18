output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "${aws_api_gateway_deployment.pii_api_deployment.invoke_url}/detect-pii"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.pii_proxy.function_name
}
