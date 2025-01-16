output "s3_bucket_id" {

  value = aws_s3_bucket_website_configuration.blog.website_endpoint

}

output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}

output "Chat-Conversations-Table" {
  value = aws_dynamodb_table.table2.arn

}

output "Chat-Messages-Table" {
  value = aws_dynamodb_table.basic-dynamodb-table.arn

}