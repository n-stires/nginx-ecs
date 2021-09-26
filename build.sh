#!/bin/bash
#
# Build and publish custom Nginx image

# Replace with ECR repo name
REPOSITORY_NAME=nginx

REPOSITORY_URI=$(aws ecr describe-repositories --repository-name ${REPOSITORY_NAME} --query 'repositories[0].repositoryUri' --output text)
if [ -z "$REPOSITORY_URI" ]; then
  echo ""
  echo "[ERROR] ECR repository not found: ${REPOSITORY_NAME}"
  echo "Check AWS CLI or repo name in build.sh"
  exit 1
fi

ECR_LOGIN=$(echo ${REPOSITORY_URI} | awk -F/ '{print $1}')

# Ensure Docker is logged into
if ! aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_LOGIN} >/dev/null; then
  echo ""
  echo "[ERROR] Docker login failed to ECR"
  echo "ECR_LOGIN=${ECR_LOGIN}"
  echo "Check AWS credentials"
  exit 1
fi

DATE_TIME_STAMP=`date +%Y%m%d%H%M`

docker build -t ${REPOSITORY_URI}:nginx-${DATE_TIME_STAMP} -t ${REPOSITORY_URI}:nginx-latest .

if [ $? -eq 0 ]; then
  docker push ${REPOSITORY_URI}:nginx-${DATE_TIME_STAMP}
  docker push ${REPOSITORY_URI}:nginx-latest
else
  echo ""
  echo "[ERROR] Docker build failed, aborting..."
  exit 1
fi
