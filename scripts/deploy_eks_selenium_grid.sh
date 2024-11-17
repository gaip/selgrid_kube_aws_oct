#!/bin/bash

echo "Starting deployment of Selenium Grid on EKS..."

# Create VPC and subnets
echo "Creating VPC and subnets..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a

aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1b

# Enable DNS hostnames and support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

# Create and attach Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create IAM roles
echo "Creating IAM roles..."
aws iam create-role \
    --role-name eksClusterRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }'

aws iam attach-role-policy \
    --role-name eksClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create EKS cluster
echo "Creating EKS cluster..."
aws eks create-cluster \
    --name selenium-grid-eks \
    --kubernetes-version 1.27 \
    --role-arn $(aws iam get-role --role-name eksClusterRole --query 'Role.Arn' --output text) \
    --resources-vpc-config subnetIds=$SUBNET_IDS,endpointPublicAccess=true

# Wait for cluster to be active
echo "Waiting for cluster to be active..."
aws eks wait cluster-active --name selenium-grid-eks

# Update kubeconfig
aws eks update-kubeconfig --name selenium-grid-eks

# Deploy Selenium Grid using Helm
echo "Deploying Selenium Grid..."
helm install selenium-grid ./helm/selenium-grid

echo "Deployment completed!"
