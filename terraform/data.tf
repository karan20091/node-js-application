data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "nodejs-app" {
  name = "nodejs-app"
}

data "aws_secretsmanager_secret_version" "documentdb-secrets" {
  secret_id     = data.aws_secretsmanager_secret.nodejs-app.id
}