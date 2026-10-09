variable "aws_region" {
  default = "ap-south-1"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.images.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.predictions.name
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
