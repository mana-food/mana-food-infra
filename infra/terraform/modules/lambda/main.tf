resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  runtime       = var.runtime         # Ex: "dotnet6" ou "dotnet8"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler         # Ex: "MeuProjeto::MeuProjeto.Function::FunctionHandler"
  filename      = var.filename        # Ex: arquivo .zip do build do C#
  timeout       = var.timeout
  memory_size   = var.memory_size
}