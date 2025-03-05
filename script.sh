#!/usr/bin/env bash
#
# script.sh - Script para gerenciar deployment no Kubernetes
#
# Opções:
#   deploy   - Cria/atualiza o stack de observabilidade e monitoramento
#   destroy  - Remove todos os recursos do stack
#   update   - Atualiza os recursos (similar ao deploy, mas pode ter lógica adicional)
#   status   - Exibe o status dos pods e serviços
#   logs     - Mostra os logs de todos os pods no namespace OU de um serviço específico
#              Adicionalmente, aceita a flag -f para seguir os logs em tempo real
#   help     - Exibe esta ajuda

# Parar a execução em caso de erro
set -e

# Nome do namespace onde serão criados os recursos
NAMESPACE="observability"

# Caminhos dos arquivos (ajuste conforme sua estrutura)
NAMESPACE_FILE="k8s/namespace.yaml"
CONFIGMAPS_FILE="k8s/configmaps.yaml"
DEPLOYMENTS_FILE="k8s/deployments.yaml"
SERVICES_FILE="k8s/services.yaml"

function check_requirements() {
  # Verifica se kubectl está instalado
  if ! command -v kubectl &> /dev/null; then
    echo "Erro: kubectl não encontrado no PATH. Instale o kubectl antes de continuar."
    exit 1
  fi
}

function deploy() {
  echo "==> Criando/Atualizando recursos no namespace '${NAMESPACE}'..."
  # 1. Cria ou atualiza o namespace
  kubectl apply -f "${NAMESPACE_FILE}"

  # 2. Aplica os ConfigMaps
  kubectl apply -f "${CONFIGMAPS_FILE}" -n "${NAMESPACE}"

  # 3. Aplica os Deployments
  kubectl apply -f "${DEPLOYMENTS_FILE}" -n "${NAMESPACE}"

  # 4. Aplica os Services
  kubectl apply -f "${SERVICES_FILE}" -n "${NAMESPACE}"

  echo "==> Deploy finalizado!"
}

function destroy() {
  echo "==> Removendo todos os recursos do stack..."
  # Remove na ordem inversa (Services, Deployments, ConfigMaps, Namespace)
  kubectl delete -f "${SERVICES_FILE}" -n "${NAMESPACE}" --ignore-not-found
  kubectl delete -f "${DEPLOYMENTS_FILE}" -n "${NAMESPACE}" --ignore-not-found
  kubectl delete -f "${CONFIGMAPS_FILE}" -n "${NAMESPACE}" --ignore-not-found
  # Por último, remove o namespace (vai apagar tudo que estiver dentro dele)
  kubectl delete -f "${NAMESPACE_FILE}" --ignore-not-found

  echo "==> Recursos removidos!"
}

function update() {
  echo "==> Atualizando recursos..."
  deploy
  echo "==> Update concluído!"
}

function status() {
  echo "==> Status dos pods no namespace '${NAMESPACE}':"
  kubectl get pods -n "${NAMESPACE}"

  echo ""
  echo "==> Status dos serviços no namespace '${NAMESPACE}':"
  kubectl get svc -n "${NAMESPACE}"
}

# Logs de todos os pods
function logs_all() {
  echo "==> Exibindo logs de todos os pods no namespace '${NAMESPACE}'..."
  pods=$(kubectl get pods -n "${NAMESPACE}" --no-headers -o custom-columns=":metadata.name")
  for pod in $pods; do
    echo "--------------------------------------------------------"
    echo "Logs do pod: $pod"
    echo "--------------------------------------------------------"
    # Se a flag follow estiver habilitada, use -f
    if [ "$1" = true ]; then
      kubectl logs -f -n "${NAMESPACE}" "$pod"
    else
      kubectl logs -n "${NAMESPACE}" "$pod"
    fi
    echo ""
  done
}

# Logs de um serviço específico (filtrando pela label app=<serviceName>)
function logs_service() {
  local serviceName="$1"
  local follow="$2"

  echo "==> Exibindo logs para o serviço '${serviceName}' no namespace '${NAMESPACE}'..."

  # Captura pods que tenham label app=<serviceName>
  pods=$(kubectl get pods -n "${NAMESPACE}" -l "app=${serviceName}" --no-headers -o custom-columns=":metadata.name")

  if [ -z "$pods" ]; then
    echo "Nenhum pod encontrado com 'app=${serviceName}'. Verifique se o label está correto."
    exit 1
  fi

  for pod in $pods; do
    echo "--------------------------------------------------------"
    echo "Logs do pod: $pod (app=${serviceName})"
    echo "--------------------------------------------------------"
    if [ "$follow" = true ]; then
      kubectl logs -f -n "${NAMESPACE}" "$pod"
    else
      kubectl logs -n "${NAMESPACE}" "$pod"
    fi
    echo ""
  done
}

function logs_menu() {
  # Se não houver argumentos, mostra todos os logs sem follow
  # Se houver um serviço e/ou a flag -f, parse os argumentos
  shift  # Remove a palavra "logs" do $@
  local follow=false
  local serviceName=""

  # Faz loop nos argumentos
  while [ $# -gt 0 ]; do
    case "$1" in
      -f|--follow)
        follow=true
        ;;
      *)
        # Consideramos que qualquer argumento que não seja -f é o nome do serviço
        serviceName="$1"
        ;;
    esac
    shift
  done

  # Se não informar um serviço, mostra logs de todos os pods
  if [ -z "$serviceName" ]; then
    logs_all "$follow"
  else
    logs_service "$serviceName" "$follow"
  fi
}

function usage() {
  echo "Uso: $0 {deploy|destroy|update|status|logs|help} [serviço] [-f]"
  echo ""
  echo "Comandos:"
  echo "  deploy   - Cria/atualiza o stack de observabilidade e monitoramento (kubectl apply)"
  echo "  destroy  - Remove todos os recursos do stack (kubectl delete)"
  echo "  update   - Atualiza recursos (semelhante ao deploy, mas pode ter lógica extra)"
  echo "  status   - Mostra os pods e serviços em execução"
  echo "  logs     - Mostra logs dos pods (pode especificar serviço e usar -f para seguir)"
  echo "  help     - Exibe esta ajuda"
  echo ""
  echo "Exemplos:"
  echo "  $0 logs                   # logs de todos os pods"
  echo "  $0 logs grafana           # logs apenas do serviço 'grafana'"
  echo "  $0 logs loki -f           # logs de 'loki' e segue em tempo real"
  exit 1
}

check_requirements

case "$1" in
  deploy)
    deploy
    ;;
  destroy)
    destroy
    ;;
  update)
    update
    ;;
  status)
    status
    ;;
  logs)
    logs_menu "$@"
    ;;
  help|*)
    usage
    ;;
esac
