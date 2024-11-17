# Selenium Grid Helm Deployment Guide

## Overview
This guide explains how to deploy Selenium Grid using Helm and run tests against it. The deployment includes a Selenium Hub and multiple Chrome nodes.

## Prerequisites
- Kubernetes cluster (local or cloud)
- Helm 3.x installed
- kubectl configured
- Maven installed
- Java 22 installed

## Quick Start

1. Deploy Selenium Grid:
```bash
helm install selenium-grid ./helm/selenium-grid
```

2. Verify deployment:
```bash
# Check pods
kubectl get pods

# Expected output:
NAME                                                  READY   STATUS    RESTARTS   AGE
selenium-grid-selenium-hub-xxxxx                      1/1     Running   0          1m
selenium-grid-selenium-node-chrome-xxxxx              1/1     Running   0          1m
```

3. Get Selenium Hub URL:
```bash
kubectl get service selenium-grid-selenium-hub
```

4. Run tests:
```bash
export SELENIUM_GRID_HOST=localhost  # Use your service IP if not local
mvn clean test -Dtest=SeleniumGridTest
```

## Configuration

### values.yaml Parameters
```yaml
hub:
  image:
    repository: selenium/hub
    tag: "4.7.2-20221219"
  replicas: 1
  service:
    type: LoadBalancer
    port: 4444

chromeNode:
  image:
    repository: selenium/node-chrome
    tag: "4.7.2-20221219"
  replicas: 3
  maxSessions: 2
```

## Verification

Check Grid status:
```bash
curl http://localhost:4444/wd/hub/status
```

Expected response:
```json
{
  "value": {
    "ready": true,
    "message": "Selenium Grid ready.",
    "nodes": [...]
  }
}
```

## Troubleshooting

1. If pods are not starting:
```bash
kubectl describe pod <pod-name>
```

2. Check Hub logs:
```bash
kubectl logs -l app=selenium-hub
```

3. Check Node logs:
```bash
kubectl logs -l app=selenium-node-chrome
```

4. Common Issues:
- Grid not ready: Wait for all pods to be in Running state
- Connection refused: Ensure service is accessible
- Test failures: Check node capacity and browser compatibility

## Cleanup

Remove deployment:
```bash
helm uninstall selenium-grid
```
