# Observabilidade e Monitorimento

Este repositório fornece um **stack de observabilidade e monitoramento** completo, reunindo Prometheus, Alertmanager, Grafana, Loki, Tempo, Promtail, Blackbox Exporter e OpenTelemetry Collector. É ideal para **ambientes de desenvolvimento** ou para quem deseja explorar ferramentas de monitoramento e tracing de forma integrada.

## Sumário

1. [Arquitetura](#arquitetura)
2. [Serviços](#serviços)
3. [Pré-requisitos](#pré-requisitos)
4. [Como Executar](#como-executar)
5. [Configurações Principais](#configurações-principais)
6. [Estrutura de Pastas](#estrutura-de-pastas)
7. [Como Contribuir](#como-contribuir)
8. [Licença](#licença)

---

## Arquitetura

A solução é composta pelos seguintes serviços, orquestrados via **Docker Compose**:

- **Prometheus**: Coleta métricas de diversos componentes, inclusive do Blackbox Exporter, e gerencia regras de alerta.
- **Alertmanager**: Gerencia o envio de notificações (por exemplo, via webhook) quando alertas do Prometheus são disparados.
- **Grafana**: Plataforma de visualização de métricas, logs e traces.
- **Loki**: Solução de coleta e armazenamento de logs.
- **Promtail**: Agente que envia logs para o Loki.
- **Tempo**: Solução de tracing distribuído.
- **OpenTelemetry Collector (otelcollector)**: Coleta e exporta métricas, logs e traces para o Prometheus, Loki e Tempo.
- **Blackbox Exporter**: Permite monitorar a disponibilidade de endpoints HTTP, HTTPS, TCP e ICMP (ping).

---

## Serviços

1. **Prometheus**  
   - Porta padrão: `9090`  
   - Armazena e processa métricas, possui regras de alerta que disparam no Alertmanager.

2. **Alertmanager**  
   - Porta padrão: `9093`  
   - Gerencia o envio de alertas, configurado para enviar notificações via webhook para o Discord (exemplo).

3. **Grafana**  
   - Porta padrão: `3000`  
   - Visualização de métricas, logs e traces. Contém datasources pré-configurados (Prometheus, Loki e Tempo).

4. **Loki**  
   - Porta padrão: `3100`  
   - Armazena logs. O Promtail coleta e envia para cá.

5. **Promtail**  
   - Sem porta exposta (usa `9080` internamente para status).  
   - Coleta logs de containers Docker (via Docker socket) e envia para o Loki.

6. **Tempo**  
   - Porta padrão: `3200`  
   - Armazena e processa traces. Recebe dados via OTLP, Jaeger, etc.

7. **OpenTelemetry Collector (otelcollector)**  
   - Portas padrão: `4317` e `4318`  
   - Recebe métricas, logs e traces (via OTLP) e exporta para Prometheus, Loki e Tempo.

8. **Blackbox Exporter**  
   - Porta padrão: `9115`  
   - Verifica a disponibilidade de endpoints HTTP/HTTPS, TCP e ICMP (configurado no `blackbox.yml`).

---

## Pré-requisitos

- **Docker** (>= 20.10) e **Docker Compose** (>= 1.29)
- Sistema operacional compatível (Linux, macOS ou Windows via WSL2, por exemplo)

---

## Como Executar

1. **Clonar o repositório**:
   ```bash
   git clone https://github.com/seu-usuario/monitoring-observability.git
   cd monitoring-observability
   ```

2. **Ajustar configurações (opcional)**:
   - Caso queira alterar endpoints, portas, regras de alerta, etc., edite os arquivos na pasta `configs/`.

3. **Subir o stack**:
   ```bash
   docker compose up -d
   ```
   Isso iniciará todos os contêineres (Prometheus, Grafana, Loki, etc.).

4. **Verificar se tudo subiu corretamente**:
   ```bash
   docker compose ps
   ```
   - Verifique se todos estão em status `Up`.

5. **Acessar os serviços**:
   - **Prometheus**: [http://localhost:9090](http://localhost:9090)
   - **Alertmanager**: [http://localhost:9093](http://localhost:9093)
   - **Grafana**: [http://localhost:3000](http://localhost:3000)
     - Usuário padrão: `admin`
     - Senha padrão: `admin`
   - **Loki**: [http://localhost:3100](http://localhost:3100)
   - **Tempo**: [http://localhost:3200](http://localhost:3200)

---

## Configurações Principais

- **Prometheus**  
  - Configurações no arquivo `configs/prometheus.yml`
  - Regras de alerta em `configs/alert-rules.yml`
  - Ajuste o `scrape_interval`, `scrape_timeout` e os targets no `job_name`.

- **Alertmanager**  
  - Configuração em `configs/alertmanager.yml`
  - Exemplo de notificação via `webhook_configs` apontando para um webhook do Discord.

- **Grafana**  
  - Datasources pré-configurados em `configs/datasource.yml`
  - Volumes persistidos em `configs/grafana` (ignorados no `.gitignore`).

- **Loki**  
  - Configuração em `configs/loki-config.yml`
  - Retenção de 7 dias definida no `storage_config`.

- **Promtail**  
  - Configuração em `configs/promtail-config.yml`
  - Coleta logs de containers com a label `logging=promtail`.

- **Tempo**  
  - Configuração em `configs/tempo-local.yml`
  - Retenção de blocos configurada para 7 dias.

- **OpenTelemetry Collector**  
  - Configuração em `configs/otel-collector.yml`
  - Recebe dados via OTLP e exporta para Prometheus, Loki e Tempo.

- **Blackbox Exporter**  
  - Configuração em `configs/blackbox.yml`
  - Módulos HTTP, TCP, ICMP e POST.

---

## Estrutura de Pastas

```
.
├── docker-compose.yml           # Orquestra todos os serviços
├── .gitignore                   # Ignora arquivos/pastas geradas em runtime
├── README.md                    # Este arquivo
└── configs/                     # Pasta de configurações
    ├── alert-rules.yml          # Regras de alerta do Prometheus
    ├── alertmanager.yml         # Configuração do Alertmanager
    ├── blackbox.yml             # Configuração do Blackbox Exporter
    ├── datasource.yml           # Datasources do Grafana
    ├── grafana/                 # Pasta persistida do Grafana (banco, plugins, etc.)
    ├── loki-config.yml          # Configuração do Loki
    ├── otel-collector.yml       # Configuração do OpenTelemetry Collector
    ├── prometheus.yml           # Configuração do Prometheus
    ├── promtail-config.yml      # Configuração do Promtail
    ├── tempo-local.yml          # Configuração do Tempo
    └── var/log                  # Diretório de logs mapeados (ignorado no Git)
```

---

## Como Contribuir

1. **Fork** o repositório e crie sua feature branch:
   ```bash
   git checkout -b minha-nova-feature
   ```
2. **Faça commits** das suas alterações:
   ```bash
   git commit -am 'Implementa minha nova feature'
   ```
3. **Envie** para o seu fork:
   ```bash
   git push origin minha-nova-feature
   ```
4. **Abra um Pull Request** explicando suas mudanças.

---

## Licença

Este projeto está sob a licença [GNU](https://www.gnu.org/licenses/gpl-3.0.txt)

---

**Observação**: Este setup é voltado para ambientes de desenvolvimento e aprendizado. Para produção, considere configurar volumes persistentes fora do repositório, armazenamento distribuído para Loki/Tempo, alta disponibilidade no Prometheus/Alertmanager e uso de mecanismos de segurança (TLS, autenticação, etc.).