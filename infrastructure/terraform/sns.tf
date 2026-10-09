resource "aws_sns_topic" "alerts" {
  name = "potato-disease-alerts"
}

# We create the topic for notifications. 
# You can manually subscribe your email address in the AWS Console later if you want real emails!
