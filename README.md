# Selenium Grid with Kubernetes Project

## Overview
This project demonstrates running Selenium tests using Selenium Grid 4 deployed on Kubernetes. It includes a sample test that runs against multiple Chrome browser instances managed by the grid.

## Prerequisites

1. Install Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
2. Install Java 22: https://www.oracle.com/java/technologies/javase/jdk22-archive-downloads.html
3. Install Maven: https://maven.apache.org/download.cgi
4. Install kubectl: https://kubernetes.io/docs/tasks/tools/
5. Access to a Kubernetes cluster (local or cloud)

## Project Structure

```
src/
├── kubectl/                          # Kubernetes configuration files
│   ├── selenium-hub-deployment.yaml  # Selenium Hub deployment
│   ├── selenium-hub-service.yaml     # Selenium Hub service
│   └── selenium-node-chrome-deployment.yaml # Chrome nodes deployment
├── test/
│   └── java/
│       └── tests/
│           └── SeleniumGridTest.java # Sample test using Selenium Grid
```

## Setup Instructions

### 1. Deploy Selenium Grid on Kubernetes

Deploy the Selenium Hub:
```sh
kubectl apply -f src/kubectl/selenium-hub-deployment.yaml
kubectl apply -f src/kubectl/selenium-hub-service.yaml
```

Deploy Chrome Nodes:
```sh
kubectl apply -f src/kubectl/selenium-node-chrome-deployment.yaml
```

### 2. Verify Deployment

Check if pods are running:
```sh
kubectl get pods
```

Expected output:
```
NAME                                               READY   STATUS    RESTARTS   AGE
selenium-hub-deployment-xxxxx                      1/1     Running   0          1m
selenium-node-chrome-deployment-xxxxx              1/1     Running   0          1m
```

Get the Selenium Hub URL:
```sh
kubectl get service selenium-hub-service
```

### 3. Run Tests

Set the Grid host (if running outside cluster):
```sh
export SELENIUM_GRID_HOST=<your-service-ip>
```

Run the test:
```sh
mvn clean test -Dtest=SeleniumGridTest
```

## Configuration Details

### Selenium Hub
- Deployment: 1 replica
- Service Type: LoadBalancer
- Ports:
  - 4444: Main hub port
  - 4442: Publisher port
  - 4443: Subscriber port

### Chrome Nodes
- Deployment: 3 replicas
- Image: seleniarm/node-chromium:latest
- Connected to hub via service discovery

## Troubleshooting

### 1. Pod Issues
Check pod status:
```sh
kubectl get pods
kubectl describe pod <pod-name>
```

### 2. Connection Issues
View Selenium Hub logs:
```sh
kubectl logs <selenium-hub-pod-name>
```

View Chrome Node logs:
```sh
kubectl logs <selenium-node-pod-name>
```

### 3. Common Problems

1. If tests can't connect to grid:
   - Verify service is running: `kubectl get service selenium-hub-service`
   - Check if nodes are registered with hub in hub logs
   - Ensure SELENIUM_GRID_HOST is set correctly

2. If tests timeout:
   - Check node capacity and scaling
   - View node logs for browser startup issues
   - Verify network connectivity between hub and nodes

## Environment Variables

- `SELENIUM_GRID_HOST`: The hostname/IP of Selenium Hub service
- Default Grid URL: `http://<SELENIUM_GRID_HOST>:4444/wd/hub`

