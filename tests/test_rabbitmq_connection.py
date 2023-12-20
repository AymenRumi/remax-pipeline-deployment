import os
import unittest

import pika


class TestRabbitMQConnection(unittest.TestCase):
    def setUp(self):
        self.host = os.getenv("RABBITMQ_HOST")
        self.api_path = "/api/health/checks/node"
        self.username = os.getenv("TF_VAR_rabbitmq_username")
        self.password = os.getenv("TF_VAR_rabbitmq_password")

    def test_ampq_connection(self):

        amqp_url = f"amqp://{self.username}:{self.password}@{self.host}"

        print(amqp_url)

        # Attempt to connect to RabbitMQ
        try:
            parameters = pika.URLParameters(amqp_url)
            connection = pika.BlockingConnection(parameters)
            connection.close()
            self.assertTrue(True, "Connection successful")
        except Exception as e:
            self.fail(f"Connection failed: {e}")
