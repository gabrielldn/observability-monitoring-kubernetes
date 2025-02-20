# Ansible Template

[![Ansible Version](https://img.shields.io/badge/Ansible-2.10%2B-blue.svg)](https://docs.ansible.com/ansible/latest/index.html)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-orange.svg)](#)

Repositório para gerenciamento e automação de configurações de infraestrutura utilizando **Ansible**.

---

## Índice

- [Descrição Geral](#descrição-geral)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Pré-Requisitos](#pré-requisitos)
- [Instalação e Configuração](#instalação-e-configuração)
- [Execução do Playbook](#execução-do-playbook)
- [Documentação Interna](#documentação-interna)
- [Licença](#licença)
- [Referências](#referências)

---

## Descrição Geral

Este projeto serve como um **template** para criar, organizar e gerenciar configurações de servidores e aplicações por meio do Ansible.  
Os arquivos e diretórios estão estruturados de forma a facilitar a manutenção, seguindo boas práticas de organização e documentação.

---

## Estrutura de Pastas

A estrutura básica do projeto é:

```
.
├── deploy.sh
├── inventories
│   └── inventory.yml
├── LICENSE
├── playbooks
│   └── deploy.yml
├── README.md
└── roles
    └── requirements.yml
```

- **inventories/**: Contém os arquivos de inventário, onde definimos os hosts, grupos e variáveis.
- **playbooks/**: Armazena os playbooks principais que definem as tarefas a serem executadas.
- **roles/**: Conjunto de funções (roles) que segmentam lógicas específicas (ex.: instalar Node Exporter, redimensionar disco, etc.).
- **deploy.sh**: Exemplo de script de automação que pode ser usado para orquestrar a execução do Ansible.
- **requirements.yml**: Lista de dependências de *roles* externas que devem ser instaladas via `ansible-galaxy`.
- **LICENSE**: Arquivo de licença do projeto.
- **README.md**: Este arquivo, que contém a documentação geral.

---

## Pré-Requisitos

- **[Python 3+](https://www.python.org/)**
- **[Ansible 2.10+](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)**  
  (A versão exata pode ser ajustada de acordo com as necessidades do projeto)
- Acesso SSH configurado para os servidores que serão gerenciados.
- (Opcional) **[Git](https://git-scm.com/)** para clonar este repositório ou baixar os roles externos.

---

## Instalação e Configuração

1. **Criar um Novo Repositório**  
   - Clique em **"Use this template"** no GitHub.  
   - Selecione **"Create a New Repository"**.  
   - Defina o nome do repositório, começando sempre com **"ansible-" seguido do restante do nome**, por exemplo, `ansible-projeto1`.  
   - Certifique-se de marcar o repositório como **privado** e de marcar a opção **Include all branches**!

2. **Clonar o Repositório Criado**  
   Após criar o repositório, clone-o para sua máquina local:  
   ```bash
   git clone https://github.com/seu-usuario/ansible-nome-do-repositorio.git
   cd ansible-nome-do-repositorio
   ```

3. **Configurar Dependências**  
   Instale as *roles* necessárias listadas no arquivo `roles/requirements.yml`:  
   ```bash
   ansible-galaxy install -r roles/requirements.yml
   ```

4. **Iniciar o Desenvolvimento**  
   Personalize os arquivos no repositório clonado conforme suas necessidades (ex.: inventário, playbooks e funções).  

---

## Execução do Playbook

Para aplicar as configurações:

```bash
ansible-playbook playbooks/deploy.yml -i inventories/inventory.yml
```

### Exemplo de Execução

1. **Expansão de disco e instalação do Node Exporter** (default do `deploy.yml`):
   ```bash
   ansible-playbook playbooks/deploy.yml -i inventories/inventory.yml
   ```

2. **Executar um script auxiliar (opcional)**:
   ```bash
   ./deploy.sh
   ```
   Caso o script `deploy.sh` contenha lógica adicional, ele poderá automatizar ainda mais o processo de deploy.

---

## Documentação Interna

Este projeto inclui comentários de documentação nos arquivos-chave:

- **Inventário** (`inventories/inventory.yml`):  
  [Documentação oficial do Ansible sobre Inventários](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html).
  
- **Playbook** (`playbooks/deploy.yml`):  
  [Documentação oficial do Ansible sobre Playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html).
  
- **Requisitos de Roles** (`roles/requirements.yml`):  
  [Documentação oficial do Ansible Galaxy sobre Requirements](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-multiple-roles-from-a-file).

Cada arquivo contém comentários detalhados, seguindo um padrão de marcações para facilitar o entendimento de cada seção.

---

## Licença

© 2023 Polícia Civil do Estado do Ceará. Todos os direitos reservados.  

Este software é proprietário e não pode ser reproduzido ou distribuído sem a permissão expressa da Polícia Civil do Estado do Ceará.  

Para dúvidas ou solicitações relacionadas ao uso deste software, entre em contato com a Polícia Civil do Estado do Ceará.

--- 

## Referências

- [Documentação Oficial do Ansible (EN)](https://docs.ansible.com/)
- [Documentação Oficial do Ansible (PT-BR) - Tradução Parcial](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)  
  *(Algumas seções podem não estar completamente traduzidas.)*
- [Shields.io](https://shields.io/) - Para criar badges personalizados.
- [Guia de melhores práticas do Ansible](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

---
