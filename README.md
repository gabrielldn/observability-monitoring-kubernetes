# Projeto  O&M Kubernetees

![Observabilidade](https://img.shields.io/badge/Observabilidade-K8s-blue)
![Versão](https://img.shields.io/badge/Vers%C3%A3o-1.0-green)
![Licença](https://img.shields.io/badge/Licen%C3%A7a-GPL%20v3-orange)

## Sumário
- [Introdução](#introdução)
- [Arquitetura](#arquitetura)
  - [Componentes](#componentes)
  - [Fluxo de Dados](#fluxo-de-dados)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
  - [Deploy do Stack](#deploy-do-stack)
  - [Verificar Status](#verificar-status)
  - [Visualizar Logs](#visualizar-logs)
  - [Atualizar Stack](#atualizar-stack)
  - [Remover Stack](#remover-stack)
- [Componentes em Detalhes](#componentes-em-detalhes)
  - [OpenTelemetry Collector](#opentelemetry-collector)
  - [Prometheus](#prometheus)
  - [Alertmanager](#alertmanager)
  - [Loki](#loki)
  - [Grafana](#grafana)
  - [Promtail](#promtail)
  - [Tempo](#tempo)
  - [Blackbox Exporter](#blackbox-exporter)
- [Configurações](#configurações)
  - [Personalização](#personalização)
  - [Alertas](#alertas)
  - [Integrações](#integrações)
- [Solução de Problemas](#solução-de-problemas)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Introdução

O ** O&M Kubernetees** é uma solução completa para implementação de um stack de observabilidade e monitoramento moderno em ambientes Kubernetes. Este projeto automatiza a implantação e gerenciamento de uma suite integrada de ferramentas para monitoramento, logging, tracing e alertas, fornecendo visibilidade abrangente sobre a infraestrutura e aplicações.

A solução é projetada seguindo os princípios das três pilares da observabilidade e monitoramento:
- **Métricas**: Coleta e visualização de métricas com Prometheus e Grafana
- **Logs**: Agregação e análise de logs com Loki e Promtail
- **Traces**: Rastreamento distribuído com Tempo

Adicionalmente, o stack inclui monitoramento de disponibilidade de endpoints externos via Blackbox Exporter e gerenciamento avançado de alertas através do Alertmanager, com integração direta a webhooks (como Discord).

## Arquitetura

### Componentes

O stack de observabilidade e monitoramento é composto pelos seguintes componentes principais:

- **OpenTelemetry Collector**: Coleta, processa e exporta dados de telemetria
- **Prometheus**: Sistema de monitoramento e alerta de séries temporais
- **Alertmanager**: Gerenciamento de alertas e notificações
- **Loki**: Sistema de agregação de logs inspirado no Prometheus
- **Grafana**: Plataforma de visualização e análise
- **Promtail**: Agente que envia logs para o Loki
- **Tempo**: Sistema de rastreamento distribuído
- **Blackbox Exporter**: Monitoramento de endpoints externos via HTTP, HTTPS, DNS, TCP e ICMP

### Fluxo de Dados

```
                  ┌─────────────┐
                  │ Aplicações  │
                  └──────┬──────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ OpenTelemetry       │
              │ Collector           │
              └───┬───────┬─────────┘
                  │       │         │
       ┌──────────┘       │         └──────────┐
       │                  │                    │
       ▼                  ▼                    ▼
┌─────────────┐    ┌─────────────┐      ┌─────────────┐
│ Prometheus   │    │    Loki     │      │   Tempo     │
│ (Métricas)   │    │   (Logs)    │      │  (Traces)   │
└──────┬───────┘    └──────┬──────┘      └──────┬──────┘
       │                   │                    │
       │                   │                    │
       └───────────┬───────┴────────────┬──────┘
                   │                    │
                   ▼                    ▼
           ┌─────────────┐      ┌─────────────┐
           │   Grafana   │      │ Alertmanager│
           │(Visualização)│     │  (Alertas)  │
           └─────────────┘      └─────────────┘
```

## Estrutura do Projeto

```
observability-monitoring-kubernetes/
├── k8s/
│   ├── configmaps.yaml    # Configurações de todos os componentes
│   ├── deployments.yaml   # Deployments Kubernetes para cada serviço
│   ├── namespace.yaml     # Definição do namespace dedicado
│   └── services.yaml      # Definições de serviços Kubernetes
├── script.sh              # Script de gerenciamento do stack
├── LICENSE                # Arquivo de licença (GNU GPL v3)
└── README.md              # Esta documentação
```

## Pré-requisitos

- **Kubernetes Cluster**: Um cluster Kubernetes funcional (Minikube, Kind, EKS, GKE, AKS, etc.)
- **kubectl**: Ferramenta de linha de comando do Kubernetes (v1.20+)
  - Instalação: [https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)
  - Configuração correta do `kubeconfig` apontando para o cluster desejado
- **Permissões**: Acesso para criar/modificar recursos no cluster (namespaces, deployments, services, configmaps)
- **Recursos Recomendados**:
  - Pelo menos 4GB de RAM disponível
  - Pelo menos 2 vCPUs 
  - Pelo menos 10GB de espaço em disco

## Instalação

1. Clone o repositório:
   ```bash
   gh repo clone gabrielldn/observability-monitoring-kubernetes
   cd observability-monitoring-kubernetes
   ```

2. Verifique se o kubectl está configurado corretamente:
   ```bash
   kubectl cluster-info
   ```

3. Dê permissão de execução ao script:
   ```bash
   chmod +x script.sh
   ```

## Uso

O script `script.sh` é o ponto central para gerenciar todo o stack de observabilidade e monitoramento.

### Deploy do Stack

Para implantar todo o stack de observabilidade e monitoramento:

```bash
./script.sh deploy
```

Este comando irá:
1. Criar o namespace `observability`
2. Aplicar todos os ConfigMaps com configurações
3. Implantar todos os componentes (Deployments)
4. Configurar os Services para comunicação entre componentes

### Verificar Status

Para verificar o status de todos os componentes:

```bash
./script.sh status
```

Este comando mostrará:
- Status de todos os pods do namespace
- Status de todos os serviços do namespace

### Visualizar Logs

Para visualizar logs, há várias opções:

```bash
# Visualizar logs de todos os pods
./script.sh logs

# Visualizar logs de um componente específico
./script.sh logs grafana

# Visualizar logs em tempo real (follow)
./script.sh logs loki -f

# Visualizar logs de um componente em tempo real
./script.sh logs prometheus -f
```

### Atualizar Stack

Para atualizar o stack após alterações nas configurações:

```bash
./script.sh update
```

### Remover Stack

Para remover completamente o stack do cluster:

```bash
./script.sh destroy
```

Este comando remove todos os recursos na seguinte ordem:
1. Serviços
2. Deployments
3. ConfigMaps
4. Namespace

## Componentes em Detalhes

### OpenTelemetry Collector

**Função**: Coleta, processa e exporta dados de telemetria (métricas, logs e traces).

**Características**:
- Suporta protocolos gRPC (porta 4317) e HTTP (porta 4318)
- Configurado para enviar:
  - Métricas para Prometheus
  - Traces para Tempo
  - Logs para Loki
- Processadores configurados para enriquecimento de dados

**Acesso**: Internamente via `otelcollector:4317` ou `otelcollector:4318`

**Configuração**: Ver `configmaps.yaml` - seção `otel-collector-config`

### Prometheus

**Função**: Sistema de monitoramento e armazenamento de métricas de séries temporais.

**Características**:
- Intervalos de scrape configurados para 15 segundos
- Coleta métricas de todos os componentes do stack
- Integrado com Blackbox Exporter para monitoramento externo
- Regras de alerta configuradas

**Acesso**: Internamente via `prometheus:9090`

**Configuração**: Ver `configmaps.yaml` - seção `prometheus-config`

### Alertmanager

**Função**: Gerencia alertas gerados pelo Prometheus, incluindo silenciamento, inibição e agrupamento.

**Características**:
- Configurado para enviar alertas para webhook Discord
- Agrupamento de alertas por 'alert' e 'job'
- Envia notificações de resolução de alertas
- Intervalo de repetição configurado para 30 minutos

**Acesso**: Internamente via `alertmanager:9093`

**Configuração**: Ver `configmaps.yaml` - seção `alertmanager-config`

### Loki

**Função**: Sistema de agregação e consulta de logs.

**Características**:
- Armazenamento local simplificado
- Retenção de logs configurável
- Integrado com Grafana para visualização
- Recebe logs de Promtail e OpenTelemetry Collector

**Acesso**: Internamente via `loki:3100`

**Configuração**: Ver `configmaps.yaml` - seção `loki-config`

### Grafana

**Função**: Plataforma de visualização e análise para métricas, logs e traces.

**Características**:
- Pré-configurado com datasources para Prometheus, Loki e Tempo
- Credenciais padrão: admin/admin
- Tema padrão configurado para "light"
- Correlação entre métricas, logs e traces

**Acesso**: Internamente via `grafana:3000`

**Configuração**: Ver `configmaps.yaml` - seção `grafana-datasource`

### Promtail

**Função**: Agente que coleta logs e os envia para o Loki.

**Características**:
- Descoberta automática de containers Docker com label "logging=promtail"
- Suporte para multi-linha e formato JSON
- Adição de labels baseados em metadados dos containers

**Acesso**: Internamente via `promtail:9080`

**Configuração**: Ver `configmaps.yaml` - seção `promtail-config`

### Tempo

**Função**: Backend de armazenamento e consulta para dados de tracing distribuído.

**Características**:
- Suporta OTLP, Jaeger e outros formatos de tracing
- Integração com Prometheus para métricas derivadas
- Integração com Grafana para visualização
- Integração com Loki para correlacionar traces com logs

**Acesso**: Internamente via `tempo:3200`

**Configuração**: Ver `configmaps.yaml` - seção `tempo-config`

### Blackbox Exporter

**Função**: Monitoramento de endpoints externos via HTTP, HTTPS, DNS, TCP e ICMP.

**Características**:
- Suporte para probes HTTP, TCP e ICMP
- Monitoramento de status de sites externos
- Utilizado pelo Prometheus para verificações de disponibilidade

**Acesso**: Internamente via `blackbox-exporter:9115`

**Configuração**: Ver `configmaps.yaml` - seção `blackbox-config`

## Configurações

### Personalização

Para personalizar o stack:

1. **Ajustar ConfigMaps**: Modifique os arquivos de configuração em `k8s/configmaps.yaml`
2. **Ajustar Recursos**: Altere limites de recursos em `k8s/deployments.yaml`
3. **Modificar Endpoints**: Ajuste os endpoints monitorados pelo Blackbox em `k8s/configmaps.yaml`
4. **Após alterações**: Execute `./script.sh update` para aplicar as modificações

### Alertas

O sistema de alertas está configurado com:

1. **Regras de Alertas**: Definidas em `alert-rules.yml` dentro do ConfigMap do Prometheus
2. **Notificações**: Configuradas para Discord em `alertmanager.yml`
3. **Personalização**:
   - Modifique as regras de alerta em `configmaps.yaml` - seção `prometheus-config`
   - Ajuste os webhooks em `configmaps.yaml` - seção `alertmanager-config`

### Integrações

O stack vem pré-configurado para integração com:

1. **Discord**: Para notificações de alertas
2. **Aplicações Instrumentadas**: Via OpenTelemetry Collector
3. **Kubernetes**: Monitoramento de recursos do cluster

Para adicionar novas integrações:
- Adicione novos receivers no OpenTelemetry Collector
- Configure novos alertmanagers no Prometheus
- Adicione novos datasources no Grafana

## Solução de Problemas

### Problemas comuns e soluções:

1. **Pods em estado CrashLoopBackOff**:
   ```bash
   # Verifique os logs do pod com problemas
   kubectl logs -n observability <nome-do-pod>
   
   # Verifique eventos do pod
   kubectl describe pod -n observability <nome-do-pod>
   ```

2. **Problemas de configuração**:
   ```bash
   # Verifique se os ConfigMaps foram criados corretamente
   kubectl get configmaps -n observability
   
   # Inspecione um ConfigMap específico
   kubectl get configmap -n observability <nome-do-configmap> -o yaml
   ```

3. **Serviços inacessíveis**:
   ```bash
   # Verifique se os endpoints estão corretos
   kubectl get endpoints -n observability
   ```

4. **Verificar conexões entre componentes**:
   ```bash
   # Use kubectl exec para fazer testes de conexão entre pods
   kubectl exec -it -n observability <nome-do-pod> -- wget -O- <serviço>:<porta>
   ```

## Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do repositório
2. Crie um branch para sua feature (`git checkout -b feature/nova-feature`)
3. Faça commit das suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Faça push para o branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Licença

Este projeto é licenciado sob a GNU General Public License v3.0 - veja o arquivo [LICENSE](LICENSE) para detalhes.

---
Desenvolvido com ❤️ para simplificar a implementação de observabilidade e monitoramento em ambientes Kubernetes.