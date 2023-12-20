import json

import boto3
import requests
from botocore.exceptions import ClientError


def log_message(message):
    print(json.dumps(message))


class SecretManager:
    def __init__(self):
        session = boto3.session.Session()
        client = session.client(service_name="secretsmanager", region_name="us-east-1")
        secret_name = "remax_secrets"

        response = client.get_secret_value(SecretID=secret_name)

        self.secret_dict = json.loads(response)

    def get_secret(self, key: str) -> str:
        return self.secret_dict[key]


def lambda_handler(event, context):

    secrets_client = SecretManager()
    secrets = {
        k: secrets_client.get_secret(f"rabbitmq_{k}")
        for k in ["username", "password", "host"]
    }

    queue_name = "celery"

    url = f"{secrets['host']}/api/queue/%2F/{queue_name}"

    response_data = {"status": "", "queue_size": None, "message": ""}

    # Get queue size
    try:
        response = requests.get(url, auth=(secrets["username"], secrets["password"]))
        response.raise_for_status()

        queue_size = response.json()["message"]
        log_message({"event": "Queue Size Fetched", "queue_size": queue_size})
        response_data["queue_size"] = queue_size

    except requests.RequestException as e:

        error_message = f"Error fetching qeue size: {e}"
        log_message({"event": "Error", "message": error_message})
        response_data.update({"status": "error", "message": error_message})
        return response_data

    #  Upadate ClouWatch Metric
    cloudwatch_client = boto3.client("cloudwatch")

    try:
        cloudwatch_client.put_metric_data(
            Namespace="RabbitMQ",
            MetricData=[
                {
                    "MetricName": "QueueSize",
                    "Dimensions": [
                        {"Name": "QueueName", "Value": queue_name},
                    ],
                    "Value": queue_size,
                    "Unit": "Count",
                },
            ],
        )
        log_message({"event": "Metric Sent to CloudWatch", "queue_size": queue_size})
        response_data["status"] = "success"

    except ClientError as e:

        error_message = f"Error sending metric to CloudWatch: {e}"
        log_message({"event": "CloudWatch Error", "message": error_message})
        response_data.update({"status": "error", "message": error_message})

    return response_data
