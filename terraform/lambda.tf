
data "archive_file" "lambda_my_function" {
    type = "zip"
    output_file_mode = "066"
    source_dir = "${path.module}/../lambda/metric/"
    output_path = "${path.module}/../lambda/metric/cloudwatch-metric.zip"
}