import json

import boto3
import requests
from botocore.exceptions import ClientError


def log_message(message: str) -> None:
    print(json.dumps(message))


class SecretManager:
    def __init__(self) -> None:
        self.secret_dict = None
        try:
            session = boto3.session.Session()
            client = session.client(
                service_name="secretsmanager", region_name="us-east-1"
            )
            secret_name = "remax-secrets"

            response = client.get_secret_value(SecretId=secret_name)
            self.secret_dict = response

        except ClientError as e:
            log_message({"event": "SecretManagerError", "message": str(e)})
            raise

    def get_secret(self, key: str) -> str:
        if self.secret_dict:
            return json.loads(self.secret_dict["SecretString"])[key]
        else:
            raise ValueError("Secrets not loaded")


def lambda_handler(event, context) -> dict:
    response_data = {"status": "", "queue_size": None, "message": ""}

    try:
        secrets_client = SecretManager()
        secrets = {
            k: secrets_client.get_secret(f"rabbitmq_{k}")
            for k in ["username", "password", "host"]
        }

        queue_name = "celery"
        url = f"{secrets['host']}/api/queues/%2F/{queue_name}"

        # Get queue size
        response = requests.get(url, auth=(secrets["username"], secrets["password"]))
        response.raise_for_status()

        queue_size = response.json()["message"]
        log_message({"event": "Queue Size Fetched", "queue_size": queue_size})
        response_data["queue_size"] = queue_size

        # Update CloudWatch Metric
        cloudwatch_client = boto3.client("cloudwatch")
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

    except requests.RequestException as e:
        error_message = f"Error fetching queue size: {e}"
        log_message({"event": "Error", "message": error_message})
        response_data.update({"status": "error", "message": error_message})

    except ClientError as e:
        error_message = f"Error with AWS Client: {e}"
        log_message({"event": "AWS Client Error", "message": error_message})
        response_data.update({"status": "error", "message": error_message})

    except Exception as e:
        error_message = f"General Error: {e}"
        log_message({"event": "General Error", "message": error_message})
        response_data.update({"status": "error", "message": error_message})

    return response_data
