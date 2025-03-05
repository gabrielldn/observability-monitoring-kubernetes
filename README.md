# O&M Kubernetes Project

![Observability](https://img.shields.io/badge/Observability-K8s-blue)
![Version](https://img.shields.io/badge/Version-1.0-green)
![License](https://img.shields.io/badge/License-GPL%20v3-orange)

## Table of Contents
- [Introduction](#introduction)
- [Architecture](#architecture)
   - [Components](#components)
   - [Data Flow](#data-flow)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
   - [Deploy the Stack](#deploy-the-stack)
   - [Check Status](#check-status)
   - [View Logs](#view-logs)
   - [Update Stack](#update-stack)
   - [Remove Stack](#remove-stack)
- [Components in Detail](#components-in-detail)
   - [OpenTelemetry Collector](#opentelemetry-collector)
   - [Prometheus](#prometheus)
   - [Alertmanager](#alertmanager)
   - [Loki](#loki)
   - [Grafana](#grafana)
   - [Promtail](#promtail)
   - [Tempo](#tempo)
   - [Blackbox Exporter](#blackbox-exporter)
- [Configurations](#configurations)
   - [Customization](#customization)
   - [Alerts](#alerts)
   - [Integrations](#integrations)
- [Troubleshooting](#troubleshooting)
- [Contribution](#contribution)
- [License](#license)

## Introduction

The **O&M Kubernetes** is a complete solution for implementing a modern observability and monitoring stack in Kubernetes environments. This project automates the deployment and management of an integrated suite of tools for monitoring, logging, tracing, and alerts, providing comprehensive visibility into infrastructure and applications.

The solution is designed following the principles of the three pillars of observability and monitoring:
- **Metrics**: Collection and visualization of metrics with Prometheus and Grafana
- **Logs**: Aggregation and analysis of logs with Loki and Promtail
- **Traces**: Distributed tracing with Tempo

Additionally, the stack includes monitoring of external endpoints via Blackbox Exporter and advanced alert management through Alertmanager, with direct integration to webhooks (such as Discord).

## Architecture

### Components

The observability and monitoring stack consists of the following main components:

- **OpenTelemetry Collector**: Collects, processes, and exports telemetry data
- **Prometheus**: Time-series monitoring and alerting system
- **Alertmanager**: Alert and notification management
- **Loki**: Log aggregation system inspired by Prometheus
- **Grafana**: Visualization and analytics platform
- **Promtail**: Agent that sends logs to Loki
- **Tempo**: Distributed tracing system
- **Blackbox Exporter**: Monitoring of external endpoints via HTTP, HTTPS, DNS, TCP, and ICMP

### Data Flow

```
                     ┌─────────────┐
                     │ Applications│
                     └──────┬──────┘
                            │
                            ▼
                  ┌─────────────────────┐
                  │ OpenTelemetry       │
                  │ Collector           │
                  └───┬───────┬─────┬───┘
                      │       │     │
           ┌──────────┘       │     └──────────┐
           │                  │                │
           ▼                  ▼                ▼
 ┌──────────────┐    ┌─────────────┐     ┌─────────────┐
 │ Prometheus   │    │    Loki     │     │   Tempo     │
 │ (Metrics)    │    │   (Logs)    │     │  (Traces)   │
 └──────┬───────┘    └──────┬──────┘     └──────┬──────┘
        │                   │                   │
        │                   │                   │
        └───────────┬───────┴────────────┬──────┘
                    │                    │
                    ▼                    ▼
             ┌─────────────┐      ┌─────────────┐
             │   Grafana   │      │ Alertmanager│
             │  (Visual)   │      │  (Alerts)   │
             └─────────────┘      └─────────────┘
```

## Project Structure

```
observability-monitoring-kubernetes/
├── k8s/
│   ├── configmaps.yaml    # Configurations for all components
│   ├── deployments.yaml   # Kubernetes deployments for each service
│   ├── namespace.yaml     # Dedicated namespace definition
│   └── services.yaml      # Kubernetes service definitions
├── script.sh              # Stack management script
├── LICENSE                # License file (GNU GPL v3)
└── README.md              # This documentation
```

## Prerequisites

- **Kubernetes Cluster**: A functional Kubernetes cluster (Minikube, Kind, EKS, GKE, AKS, etc.)
- **kubectl**: Kubernetes command-line tool (v1.20+)
   - Installation: [https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)
   - Correct configuration of `kubeconfig` pointing to the desired cluster
- **Permissions**: Access to create/modify resources in the cluster (namespaces, deployments, services, configmaps)
- **Recommended Resources**:
   - At least 4GB of available RAM
   - At least 2 vCPUs 
   - At least 10GB of disk space

## Installation

1. Clone the repository:
    ```bash
    gh repo clone gabrielldn/observability-monitoring-kubernetes
    cd observability-monitoring-kubernetes
    ```

2. Verify that kubectl is correctly configured:
    ```bash
    kubectl cluster-info
    ```

3. Grant execution permission to the script:
    ```bash
    chmod +x script.sh
    ```

## Usage

The `script.sh` script is the central point for managing the entire observability and monitoring stack.

### Deploy the Stack

To deploy the entire observability and monitoring stack:

```bash
./script.sh deploy
```

This command will:
1. Create the `observability` namespace
2. Apply all ConfigMaps with configurations
3. Deploy all components (Deployments)
4. Configure the Services for communication between components

### Check Status

To check the status of all components:

```bash
./script.sh status
```

This command will show:
- Status of all pods in the namespace
- Status of all services in the namespace

### View Logs

To view logs, there are several options:

```bash
# View logs of all pods
./script.sh logs

# View logs of a specific component
./script.sh logs grafana

# View logs in real-time (follow)
./script.sh logs loki -f

# View logs of a component in real-time
./script.sh logs prometheus -f
```

### Update Stack

To update the stack after configuration changes:

```bash
./script.sh update
```

### Remove Stack

To completely remove the stack from the cluster:

```bash
./script.sh destroy
```

This command removes all resources in the following order:
1. Services
2. Deployments
3. ConfigMaps
4. Namespace

## Components in Detail

### OpenTelemetry Collector

**Function**: Collects, processes, and exports telemetry data (metrics, logs, and traces).

**Features**:
- Supports gRPC (port 4317) and HTTP (port 4318) protocols
- Configured to send:
   - Metrics to Prometheus
   - Traces to Tempo
   - Logs to Loki
- Processors configured for data enrichment

**Access**: Internally via `otelcollector:4317` or `otelcollector:4318`

**Configuration**: See `configmaps.yaml` - section `otel-collector-config`

### Prometheus

**Function**: Time-series monitoring and alerting system.

**Features**:
- Scrape intervals configured to 15 seconds
- Collects metrics from all stack components
- Integrated with Blackbox Exporter for external monitoring
- Alert rules configured

**Access**: Internally via `prometheus:9090`

**Configuration**: See `configmaps.yaml` - section `prometheus-config`

### Alertmanager

**Function**: Manages alerts generated by Prometheus, including silencing, inhibition, and grouping.

**Features**:
- Configured to send alerts to Discord webhook
- Alert grouping by 'alert' and 'job'
- Sends alert resolution notifications
- Repeat interval configured to 30 minutes

**Access**: Internally via `alertmanager:9093`

**Configuration**: See `configmaps.yaml` - section `alertmanager-config`

### Loki

**Function**: Log aggregation and query system.

**Features**:
- Simplified local storage
- Configurable log retention
- Integrated with Grafana for visualization
- Receives logs from Promtail and OpenTelemetry Collector

**Access**: Internally via `loki:3100`

**Configuration**: See `configmaps.yaml` - section `loki-config`

### Grafana

**Function**: Visualization and analytics platform for metrics, logs, and traces.

**Features**:
- Pre-configured with datasources for Prometheus, Loki, and Tempo
- Default credentials: admin/admin
- Default theme set to "light"
- Correlation between metrics, logs, and traces

**Access**: Internally via `grafana:3000`

**Configuration**: See `configmaps.yaml` - section `grafana-datasource`

### Promtail

**Function**: Agent that collects logs and sends them to Loki.

**Features**:
- Automatic discovery of Docker containers with label "logging=promtail"
- Support for multi-line and JSON format
- Addition of labels based on container metadata

**Access**: Internally via `promtail:9080`

**Configuration**: See `configmaps.yaml` - section `promtail-config`

### Tempo

**Function**: Backend for storing and querying distributed tracing data.

**Features**:
- Supports OTLP, Jaeger, and other tracing formats
- Integration with Prometheus for derived metrics
- Integration with Grafana for visualization
- Integration with Loki to correlate traces with logs

**Access**: Internally via `tempo:3200`

**Configuration**: See `configmaps.yaml` - section `tempo-config`

### Blackbox Exporter

**Function**: Monitoring of external endpoints via HTTP, HTTPS, DNS, TCP, and ICMP.

**Features**:
- Support for HTTP, TCP, and ICMP probes
- Monitoring of external site status
- Used by Prometheus for availability checks

**Access**: Internally via `blackbox-exporter:9115`

**Configuration**: See `configmaps.yaml` - section `blackbox-config`

## Configurations

### Customization

To customize the stack:

1. **Adjust ConfigMaps**: Modify the configuration files in `k8s/configmaps.yaml`
2. **Adjust Resources**: Change resource limits in `k8s/deployments.yaml`
3. **Modify Endpoints**: Adjust the endpoints monitored by Blackbox in `k8s/configmaps.yaml`
4. **After changes**: Run `./script.sh update` to apply the modifications

### Alerts

The alert system is configured with:

1. **Alert Rules**: Defined in `alert-rules.yml` within the Prometheus ConfigMap
2. **Notifications**: Configured for Discord in `alertmanager.yml`
3. **Customization**:
    - Modify alert rules in `configmaps.yaml` - section `prometheus-config`
    - Adjust webhooks in `configmaps.yaml` - section `alertmanager-config`

### Integrations

The stack comes pre-configured for integration with:

1. **Discord**: For alert notifications
2. **Instrumented Applications**: Via OpenTelemetry Collector
3. **Kubernetes**: Monitoring of cluster resources

To add new integrations:
- Add new receivers in the OpenTelemetry Collector
- Configure new alertmanagers in Prometheus
- Add new datasources in Grafana

## Troubleshooting

### Common issues and solutions:

1. **Pods in CrashLoopBackOff state**:
    ```bash
    # Check the logs of the problematic pod
    kubectl logs -n observability <pod-name>
    
    # Check pod events
    kubectl describe pod -n observability <pod-name>
    ```

2. **Configuration issues**:
    ```bash
    # Check if ConfigMaps were created correctly
    kubectl get configmaps -n observability
    
    # Inspect a specific ConfigMap
    kubectl get configmap -n observability <configmap-name> -o yaml
    ```

3. **Inaccessible services**:
    ```bash
    # Check if endpoints are correct
    kubectl get endpoints -n observability
    ```

4. **Check connections between components**:
    ```bash
    # Use kubectl exec to test connections between pods
    kubectl exec -it -n observability <pod-name> -- wget -O- <service>:<port>
    ```

## Contribution

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

---
Developed with ❤️ to simplify the implementation of observability and monitoring in Kubernetes environments.