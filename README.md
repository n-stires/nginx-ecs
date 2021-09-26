# nginx-ecs

## Prerequisites

1. [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

2. [Docker](https://docs.docker.com/get-docker/)

3. [ECS Cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html) that will host Service.

4. [ACM Certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)

## Nginx Image

We're baking the config into the image here. Longer-term options to manage config include
[AppConfig](https://aws.amazon.com/blogs/mt/application-configuration-deployment-to-container-workloads-using-aws-appconfig/) 
for the /etc/nginx/ configuration, and [EFS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/tutorial-efs-volumes.html) 
for the webroot (/usr/share/nginx/html).

This example configuration uses the "stable" Nginx tag, others can be found here: [Nginx Docker](https://hub.docker.com/_/nginx)

Modify the Dockerfile accordingly to change the base image.

### Create Elastic Container Registry to host the custom image

```bash
aws ecr create-repository --repository-name nginx
```

### Build/Update/Push the image

```bash
./build.sh
```

## Deploying to AWS

Replace below parameters per environment.

```bash
aws cloudformation create-stack --stack-name nginx-ecs-example --disable-rollback --template-body file://deploy.yml \
  --parameters \
    ParameterKey=VpcId,ParameterValue=vpc-000000000000 \
    ParameterKey=AlbSubnet1,ParameterValue=subnet-000000000000 \
    ParameterKey=AlbSubnet2,ParameterValue=subnet-000000000000 \
    ParameterKey=EcsClusterArn,ParameterValue=arn:aws:ecs:us-east-1:000000000000:cluster/default \
    ParameterKey=CertificateArn,ParameterValue=arn:aws:acm:us-east-1:000000000000:certificate/111111111111-222222222-33333 \
    ParameterKey=Image,ParameterValue=000000000000.dkr.ecr.us-east-1.amazonaws.com/nginx:nginx-11111111 \
  --capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM
```

### Scaling Nginx Server

[Documentation](https://www.nginx.com/blog/tuning-nginx/)

1. [worker_processes](https://nginx.org/en/docs/ngx_core_module.html#worker_processes) Adjust the number of processes to equal the number of CPUs allocated in each ECS Task.

2. [worker_connections](https://nginx.org/en/docs/ngx_core_module.html#worker_connections) Allow up to 512 connections for each "worker_processes" set.

### Scaling ECS Service

1. Allow the service to perform autoscaling to meet traffic demands. [Documentation](https://aws.amazon.com/premiumsupport/knowledge-center/ecs-fargate-service-auto-scaling/) 
Cloudformation template also hosts disabled autoscaling configuration.

2. Consider [Scheduled Scaling](https://aws.amazon.com/blogs/containers/optimizing-amazon-elastic-container-service-for-cost-using-scheduled-scaling/)
per forecasted high traffic times.


