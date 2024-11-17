# GitHub Actions Workflow for AWS EKS Selenium Grid

## Overview
This workflow automates the process of:
1. Deploying Selenium Grid on AWS EKS
2. Running tests
3. Cleaning up all AWS resources

## Prerequisites

### 1. AWS IAM Setup
Create an IAM role with the following permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ec2:*",
                "iam:*",
                "autoscaling:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### 2. GitHub Secrets
Configure the following secrets in your GitHub repository:
- `AWS_ROLE_ARN`: The ARN of the IAM role created above

## Workflow Structure

### 1. Trigger
The workflow is triggered manually (workflow_dispatch) with the following input:
- `aws_region`: AWS region for deployment (default: us-east-1)

### 2. Jobs
Single job `deploy-test-cleanup` that:
1. Sets up AWS credentials
2. Deploys EKS cluster
3. Runs tests
4. Cleans up resources

### 3. Key Steps
```yaml
- Deploy EKS Infrastructure
- Wait for Grid Readiness
- Run Selenium Tests
- Report Results
- Cleanup AWS Resources
```

## Usage

1. Go to GitHub Actions tab in your repository
2. Select "AWS EKS Selenium Grid Tests"
3. Click "Run workflow"
4. Enter AWS region if different from default
5. Click "Run workflow"

## Monitoring

1. Watch the workflow progress in GitHub Actions UI
2. Test results are published using dorny/test-reporter
3. Cleanup status is reported in the final step

## Cleanup Verification
After workflow completion:
1. No EKS clusters should remain
2. No EC2 instances should be running
3. All IAM roles and policies should be removed
4. VPC and networking resources should be deleted

## Troubleshooting

### Common Issues
1. Insufficient IAM permissions:
   - Check AWS role permissions
   - Verify GitHub secret configuration

2. Resource deletion failures:
   - Check AWS console for stuck resources
   - Run cleanup script manually if needed

3. Test failures:
   - Check test reports
   - Verify Selenium Grid status in logs

### Logs
Important log locations:
1. GitHub Actions workflow logs
2. AWS CloudWatch logs (if enabled)
3. Maven test reports

## Cost Considerations
Resources that incur costs:
1. EKS cluster
2. EC2 instances
3. Load Balancer
4. Data transfer

Note: Resources are automatically cleaned up to minimize costs
