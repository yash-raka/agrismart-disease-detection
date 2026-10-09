resource "aws_cognito_user_pool" "pool" {
  name = "potato_farmers_pool"

  # Allow farmers to sign up with email
  alias_attributes = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "potato_frontend_app"
  user_pool_id = aws_cognito_user_pool.pool.id
  
  # Allow the frontend to authenticate users without a backend secret
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}
