# Data Pipeline AWS Infrastructure Management and Deployment

## Overview

This repository contains `Terraform` configurations and `bash scripts` for managing a scalable and efficient AWS infrastructure. It primarily focuses on setting up `RabbitMQ` with EC2 and Docker, automating `Lambda functions` for queue monitoring, autoscaling, and task triggering, and integrating other AWS services like `RDS`, `Secrets Manager`, `VPC`, and `ECR`.

The infrastructure and deployment of the data pipeline relies on the `remax-pipeline` library found [here](https://pypi.org/project/remax-pipeline/).

## Diagram

<img src="https://github.com/AymenRumi/remax-pipeline-deployment/blob/main/assets/diagram.png">