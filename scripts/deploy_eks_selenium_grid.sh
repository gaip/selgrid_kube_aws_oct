
#!/bin/bash

# Variables
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR_1="10.0.1.0/24"
SUBNET_CIDR_2="10.0.2.0/24"
REGION="us-east-1"
CLUSTER_NAME="selenium-grid-eks"
NODEGROUP_NAME="selenium-grid-nodes"
INSTANCE_TYPE="t3.medium"
MIN_SIZE=2
MAX_SIZE=4
DESIRED_SIZE=3
ROLE_NAME_CLUSTER="eksClusterRole"
ROLE_NAME_NODEGROUP="eksNodeGroupRole"
POLICY_ARN_CLUSTER="arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
POLICY_ARN_NODEGROUP="arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
POLICY_ARN_CNI="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
POLICY_ARN_ECR="arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

# Create Subnets
SUBNET_ID_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_1 --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
SUBNET_ID_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_2 --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text)

# Create IAM Roles
aws iam create-role --role-name $ROLE_NAME_CLUSTER --assume-role-policy-document '{
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
aws iam attach-role-policy --role-name $ROLE_NAME_CLUSTER --policy-arn $POLICY_ARN_CLUSTER

aws iam create-role --role-name $ROLE_NAME_NODEGROUP --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'
aws iam attach-role-policy --role-name $ROLE_NAME_NODEGROUP --policy-arn $POLICY_ARN_NODEGROUP
aws iam attach-role-policy --role-name $ROLE_NAME_NODEGROUP --policy-arn $POLICY_ARN_CNI
aws iam attach-role-policy --role-name $ROLE_NAME_NODEGROUP --policy-arn $POLICY_ARN_ECR

# Create EKS Cluster
aws eks create-cluster --region $REGION --name $CLUSTER_NAME --kubernetes-version 1.27 --role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME_CLUSTER --resources-vpc-config subnetIds=$SUBNET_ID_1,$SUBNET_ID_2,endpointPublicAccess=true

# Wait for cluster to be active
aws eks wait cluster-active --name $CLUSTER_NAME

# Tag Subnets
aws ec2 create-tags --resources $SUBNET_ID_1 $SUBNET_ID_2 --tags Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=shared Key=kubernetes.io/role/elb,Value=1

# Create Node Group
aws eks create-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --node-role arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME_NODEGROUP --subnets $SUBNET_ID_1 $SUBNET_ID_2 --instance-types $INSTANCE_TYPE --scaling-config minSize=$MIN_SIZE,maxSize=$MAX_SIZE,desiredSize=$DESIRED_SIZE

# Wait for node group to be active
aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME

# Configure kubectl
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Deploy Selenium Grid using Helm
helm install selenium-grid ./helm/selenium-grid

echo "Deployment complete. Verify with 'kubectl get pods' and 'kubectl get services'."