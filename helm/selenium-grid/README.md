# Selenium Grid Helm Deployment Guide

[Previous sections remain unchanged...]

## Test Configuration Setup

### 1. Active Configurations

The test execution uses multiple configuration layers:

1. **Kubernetes Configuration**
```bash
# Check active context
kubectl config get-contexts
```
Expected output:
```
CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
*         docker-desktop   docker-desktop   docker-desktop   
```

2. **Application Configuration**
- Location: `src/main/resources/configuration.properties`
- Key settings:
  ```properties
  url=https://practicesoftwaretesting.com/
  selenium.gridurl=
  ```
  - When `selenium.gridurl` is empty, it uses the Kubernetes service URL
  - When set, it overrides the default Grid URL

3. **Environment Variables**
```bash
export SELENIUM_GRID_HOST=localhost  # For local Kubernetes
# or
export SELENIUM_GRID_HOST=<service-ip>  # For remote Kubernetes
```

### 2. Configuration Priority

1. Environment variables (`SELENIUM_GRID_HOST`)
2. Properties file (`configuration.properties`)
3. Default Kubernetes service URL (`selenium-grid-selenium-hub`)

### 3. Verifying Active Configuration

1. Check Kubernetes service:
```bash
kubectl get service selenium-grid-selenium-hub
```

2. Verify Grid status:
```bash
curl http://$SELENIUM_GRID_HOST:4444/wd/hub/status
```

3. Check application properties:
```bash
cat src/main/resources/configuration.properties
```

[Rest of documentation remains unchanged...]
