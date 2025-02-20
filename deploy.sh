#!/bin/bash

# Defina o nível de verbosidade padrão
verbosity_level=1
PLAYBOOK=playbooks/deploy.yml
INVENTORY=inventories/inventory.yml
# Verifique se o script está sendo executado diretamente
if [ "$0" = "$BASH_SOURCE" ]; then
    # Instalar roles necessárias
    echo "Instalando roles necessárias..."
    ansible-galaxy install -r roles/requirements.yml --force

    # Executar o playbook principal com a verbosidade definida
    case $verbosity_level in
        1)
            ansible-playbook -vv $PLAYBOOK -i inventories/inventory.yml
            ;;
        2)
            ansible-playbook -vvv $PLAYBOOK -i inventories/inventory.yml
            ;;
        3)
            ansible-playbook -vvvv $PLAYBOOK -i inventories/inventory.yml
            ;;
        *)
            echo "Nível de verbosidade inválido. Saindo..."
            exit 1
            ;;
    esac
fi