
data "archive_file" "lambda_my_function" {
    type = "zip"
    output_file_mode = "066"
    source_dir = "${path.module}/../lambda/rabbitmq-cloudwatch-autoscale/"
    output_path = "${path.module}/../lambda/rabbitmq-cloudwatch-autoscale/cloudwatch-autoscale.zip"
}


resource "aws_lambda_function" "rabbitmq_autoscale" {
  filename = "${path.module}/../lambda/rabbitmq-cloudwatch-autoscale/cloudwatch-autoscale.zip"
  function_name = "rabbitmq_cloudwatch_autoscale"
  handler       = "cloudwatch-autoscale.lambda_handler"
  runtime       = "python3.11"


  role = aws_iam_role.lambda_iam_role.arn

  memory_size = 128
  timeout     = 30

  layers = [aws_lambda_layer_version.my-lambda-layer.arn]

}