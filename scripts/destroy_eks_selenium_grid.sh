#!/bin/bash

echo "Starting cleanup of Selenium Grid EKS deployment..."

# Delete cluster
echo "Deleting EKS cluster..."
aws eks delete-cluster --name selenium-grid-eks

# Wait for cluster deletion
echo "Waiting for cluster deletion..."
while aws eks describe-cluster --name selenium-grid-eks >/dev/null 2>&1; do
    echo "Cluster still deleting..."
    sleep 30
done
echo "Cluster deleted"

# Delete IAM roles and policies
echo "Cleaning up IAM roles and policies..."
aws iam detach-role-policy --role-name eksClusterRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name eksClusterRole

aws iam detach-role-policy --role-name eksNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy --role-name eksNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam detach-role-policy --role-name eksNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam delete-role --role-name eksNodeGroupRole

# Clean up VPC resources
echo "Cleaning up VPC resources..."
# Detach and delete Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=vpc-000e3f8524acfb89d" --query 'InternetGateways[0].InternetGatewayId' --output text)
if [ ! -z "$IGW_ID" ]; then
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id vpc-000e3f8524acfb89d
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi

# Delete subnets and VPC
aws ec2 delete-subnet --subnet-id subnet-08ada63b767485389
aws ec2 delete-subnet --subnet-id subnet-0b3fba41acdb0b8ed
aws ec2 delete-vpc --vpc-id vpc-000e3f8524acfb89d

echo "All resources have been destroyed."
