# Deploying Selenium Grid on AWS EKS - Complete Guide

[Previous sections remain unchanged...]

## Cleanup Process
Follow these steps to completely remove all resources:

### 1. Delete Helm Release and Check Running Resources
```bash
# Delete Helm release
helm uninstall selenium-grid

# Check for any running pods
kubectl get pods
```

### 2. Delete EKS Node Group
```bash
# Delete node group and wait for completion
aws eks delete-nodegroup \
    --cluster-name selenium-grid-eks \
    --nodegroup-name selenium-grid-nodes

# Monitor deletion status
aws eks describe-nodegroup \
    --cluster-name selenium-grid-eks \
    --nodegroup-name selenium-grid-nodes \
    --query 'nodegroup.status'
```

### 3. Delete EKS Cluster
```bash
# Delete cluster
aws eks delete-cluster --name selenium-grid-eks

# Monitor cluster deletion
aws eks describe-cluster \
    --name selenium-grid-eks \
    --query 'cluster.status'
```

### 4. Clean Up IAM Roles
```bash
# Remove cluster role
aws iam detach-role-policy \
    --role-name eksClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name eksClusterRole

# Remove node group role
aws iam detach-role-policy \
    --role-name eksNodeGroupRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy \
    --role-name eksNodeGroupRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam detach-role-policy \
    --role-name eksNodeGroupRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam delete-role --role-name eksNodeGroupRole
```

### 5. Clean Up VPC Resources
```bash
# Remove Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=vpc-000e3f8524acfb89d" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text)
aws ec2 detach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id vpc-000e3f8524acfb89d
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# Delete subnets and VPC
aws ec2 delete-subnet --subnet-id subnet-08ada63b767485389
aws ec2 delete-subnet --subnet-id subnet-0b3fba41acdb0b8ed
aws ec2 delete-vpc --vpc-id vpc-000e3f8524acfb89d
```

### 6. Verify Cleanup
```bash
# Verify all resources are deleted
aws eks describe-cluster --name selenium-grid-eks || echo "Cluster: Deleted"
aws iam get-role --role-name eksClusterRole || echo "Cluster Role: Deleted"
aws iam get-role --role-name eksNodeGroupRole || echo "Node Role: Deleted"
aws ec2 describe-vpc --vpc-id vpc-000e3f8524acfb89d || echo "VPC: Deleted"
```

### Common Cleanup Issues
1. Node group stuck in DELETING state:
   - Check and force delete associated Auto Scaling Groups
   - Manually terminate any stuck EC2 instances

2. VPC deletion fails:
   - Ensure all dependencies (Internet Gateways, NAT Gateways) are removed
   - Check for any remaining EC2 instances or ENIs

3. IAM role deletion fails:
   - Ensure all policies are detached before deleting roles
   - Check for any services still using the roles

[Rest of file remains unchanged...]
