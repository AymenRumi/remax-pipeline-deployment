resource "aws_cloudwatch_event_rule" "every_minute_between_1_and_2_pm" {
  name                = "every_minute_between_1_and_2_pm"
  schedule_expression = "cron(30-59 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.every_minute_between_1_and_2_pm.name
  target_id = "TriggerLambdaFunction"
  arn       = aws_lambda_function.rabbitmq_monitor.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rabbitmq_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute_between_1_and_2_pm.arn
}
