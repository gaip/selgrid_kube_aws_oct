
#!/bin/bash

# Variables
CLUSTER_NAME="selenium-grid-eks"
NODEGROUP_NAME="selenium-grid-nodes"
ROLE_NAME_CLUSTER="eksClusterRole"
ROLE_NAME_NODEGROUP="eksNodeGroupRole"
REGION="us-east-1"

# Delete Helm release
helm uninstall selenium-grid

# Delete Node Group
aws eks delete-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME

# Wait for node group to be deleted
aws eks wait nodegroup-deleted --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME

# Delete EKS Cluster
aws eks delete-cluster --name $CLUSTER_NAME

# Wait for cluster to be deleted
aws eks wait cluster-deleted --name $CLUSTER_NAME

# Delete IAM roles and policies
aws iam detach-role-policy --role-name $ROLE_NAME_CLUSTER --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name $ROLE_NAME_CLUSTER

aws iam detach-role-policy --role-name $ROLE_NAME_NODEGROUP --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy --role-name $ROLE_NAME_NODEGROUP --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam detach-role-policy --role-name $ROLE_NAME_NODEGROUP --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam delete-role --role-name $ROLE_NAME_NODEGROUP

# Delete VPC resources
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=cidr-block,Values=10.0.0.0/16" --query "Vpcs[0].VpcId" --output text)
SUBNET_ID_1=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=cidr-block,Values=10.0.1.0/24" --query "Subnets[0].SubnetId" --output text)
SUBNET_ID_2=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=cidr-block,Values=10.0.2.0/24" --query "Subnets[0].SubnetId" --output text)

aws ec2 delete-subnet --subnet-id $SUBNET_ID_1
aws ec2 delete-subnet --subnet-id $SUBNET_ID_2
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "All resources have been destroyed."