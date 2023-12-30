#!/bin/bash


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' 


DIR_PATH="lambda/rabbitmq-cloudwatch-monitor"
PYTHON_FILE="cloudwatch-monitor.py"
ZIP_FILE="cloudwatch-monitor.zip"                
FUNCTION_NAME="rabbitmq_queue_monitor"   


cd $DIR_PATH

zip $ZIP_FILE $PYTHON_FILE



if [ $? -ne 0 ]; then
    echo "${RED}Failed to create ZIP file.${NC}"
    exit 1
fi

echo "${GREEN} ZIP file created successfully${NC}"

aws lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --zip-file fileb://$ZIP_FILE > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "${GREEN}Lambda function updated successfully.${NC}"
    rm -f $ZIP_FILE
    echo "${GREEN}ZIP file removed.${NC}"
else
    echo "${RED}Failed to update the Lambda function.${NC}"
fi
