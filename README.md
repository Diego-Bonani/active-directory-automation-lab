# Laboratório Automatizado de Active Directory: IAM & RBAC como Código

*[Read this project in English here](README-EN.md)*

Este repositório contém um projeto completo de infraestrutura automatizada desenvolvido para implantar um ambiente seguro de **Active Directory (AD)** utilizando **PowerShell** e conceitos de **Infraestrutura como Código (IaC)**.

O objetivo principal é automatizar o processo de onboarding de **Gestão de Identidades e Acessos (IAM)** e aplicar o **Controle de Acesso Baseado em Funções (RBAC)** entre diferentes departamentos.

## 🛠️ Arquitetura da Infraestrutura
* **Controlador de Domínio (DC):** Windows Server 2022 Evaluation (Desktop Experience)
* **Estação de Trabalho Cliente:** Windows 11 / Windows 10 Enterprise
* **Rede do Hipervisor:** Ambiente isolado em **Rede Interna (`AD-Lab`)** no Oracle VirtualBox utilizando roteamento de IP estático (`192.168.10.0/24`) e alinhamento de DNS loopback.

## 🚀 Recursos Implementados

### 1. Onboarding Automatizado via Ingestão de Dados Externos (IaC)
* Criação de um pipeline de automação em PowerShell que importa dados cadastrais de colaboradores a partir de um arquivo `.csv` externo (`Import-Csv`).
* **Provisionamento Dinâmico de Atributos:** Trata strings automaticamente para gerar identidades corporativas padronizadas (`nome.sobrenome`), User Principal Names (UPN) e descrições de conta.
* **Segurança e Conformidade:** Aplica uma política estática de senha inicial complexa, forçando a rotação obrigatória de credenciais (`-ChangePasswordAtLogon $true`) logo no primeiro logon do usuário na estação.

### 2. Controle de Acesso Baseado em Funções (RBAC) e Estrutura de Diretório
* Construção de uma árvore hierárquica limpa via injeção programática de **Unidades Organizacionais (OUs)**, separando o diretório raiz (`Empresa_Lab`) por setores comerciais (`TI`, `RH`, `Vendas`) e uma estrutura centralizada para componentes de privilégio (`Grupos`).
* Provisionamento automático de **Grupos de Segurança Globais** (`GG_NomeDoDepartamento`) e gestão automatizada de membros sem sobreposição de dados.

### 3. Mapeamento Dinâmico de Drives de Rede via GPO Avançada
* Implementação de uma **Diretiva de Grupo (GPO)** para mapear storages compartilhados de forma transparente com base no token de segurança de cada usuário.
* Utilização de **Item-level Targeting** (Mira a Nível de Item) nas Preferências da GPO:
  * Usuários do grupo `GG_TI` montam automaticamente o caminho `\\192.168.10.10\TI$` na letra `Z:`.
  * Usuários do grupo `GG_RH` montam automaticamente o caminho `\\192.168.10.10\RH$` na letra `Y:`.
* Aplicação de hardening de segurança através de compartilhamentos ocultos (`$`) alinhados a listas de controle de acesso rígidas (ACLs NTFS/SMB).

## 📁 Estrutura do Repositório
* `provision_users.ps1`: O script principal de automação de provisionamento.
* `usuarios.csv`: Planilha externa de dados para testes de contratação em lote.

## 🔍 Como Executar Este Projeto
1. Configure seu Windows Server 2022 como Controlador de Domínio em uma rede interna isolada no VirtualBox.
2. Salve o arquivo `usuarios.csv` no diretório `C:\Compartilhamentos\`.
3. Abra o **PowerShell ISE (Como Administrador)** e execute o script `provision_users.ps1`.
4. Faça login na máquina cliente com Windows 11 usando uma das novas contas criadas para validar a aplicação das diretivas e os mapeamentos de rede.
