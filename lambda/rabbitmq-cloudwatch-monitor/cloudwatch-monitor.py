import datetime
import json

import boto3
import requests
from botocore.exceptions import ClientError


def log_message(message: str) -> None:
    print(json.dumps(message))


class AutoScale:
    def __init__(self) -> None:
        self.cloudwatch_client = boto3.client("cloudwatch")
        self.autoscale_client = boto3.client("autoscaling")
        self.autoscaling_group_name = SecretManager().get_secret(
            "celery_autoscaling_group"
        )

    def _scale_up(self):

        self.autoscale_client.set_desired_capacity(
            AutoScalingGroupName=self.autoscaling_group_name, DesiredCapacity=5
        )

        return {"autoscale": True, "capacity": 5}

    def _scale_down(self):
        self.autoscale_client.set_desired_capacity(
            AutoScalingGroupName=self.autoscaling_group_name, DesiredCapacity=0
        )

        return {"autoscale": True, "capacity": 0}

    def scale_celery_workers(self):
        """checks if tasks are being added to queue or removed from queue"""

        end_time = datetime.datetime.utcnow()
        start_time = end_time - datetime.timedelta(seconds=120)

        response = self.cloudwatch_client.get_metric_statistics(
            MetricName="QueueSize",
            Namespace="RabbitMQ",
            Dimensions=[
                {
                    "Name": "QueueName",
                    "Value": "celery",
                },
            ],
            Period=60,
            StartTime=start_time,
            EndTime=end_time,
            Statistics=["Maximum", "Average", "Minimum"],
        )

        datapoints = response["Datapoints"]
        datapoints.sort(key=lambda x: x["Timestamp"])

        datapoints = [i["Minimum"] for i in datapoints]

        first_point = datapoints[0]
        last_point = datapoints[-1]

        return (
            self._scale_up()
            if last_point > first_point and first_point == 0
            else self._scale_down()
            if first_point > last_point and last_point == 0
            else {"autoscale": False}
        )


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
        url = f"http://{secrets['host']}:15672/api/queues/%2F/{queue_name}"

        # Get queue size
        response = requests.get(url, auth=(secrets["username"], secrets["password"]))
        response.raise_for_status()

        queue_size = response.json()["messages"]
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

        log_message(AutoScale().scale_celery_workers())
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
