#!/bin/bash

# Delete Helm release if exists
helm uninstall selenium-grid

# Delete node group
aws eks delete-nodegroup \
    --cluster-name selenium-grid-eks \
    --nodegroup-name selenium-grid-nodes

# Wait for node group deletion
echo "Waiting for node group deletion..."
aws eks wait nodegroup-deleted \
    --cluster-name selenium-grid-eks \
    --nodegroup-name selenium-grid-nodes

# Delete cluster
aws eks delete-cluster --name selenium-grid-eks

# Wait for cluster deletion
echo "Waiting for cluster deletion..."
aws eks wait cluster-deleted --name selenium-grid-eks

# Delete IAM roles and policies
aws iam detach-role-policy --role-name eksClusterRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name eksClusterRole

aws iam detach-role-policy --role-name eksNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy --role-name eksNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam detach-role-policy --role-name eksNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam delete-role --role-name eksNodeGroupRole

# Delete VPC and related resources
aws ec2 delete-subnet --subnet-id subnet-08ada63b767485389
aws ec2 delete-subnet --subnet-id subnet-0b3fba41acdb0b8ed
aws ec2 delete-vpc --vpc-id vpc-000e3f8524acfb89d

echo "All resources have been destroyed."