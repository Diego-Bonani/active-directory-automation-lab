# Automated Active Directory Lab: IAM & RBAC Infrastructure as Code

This repository contains an automated infrastructure project designed to deploy a secure, enterprise-grade **Active Directory (AD)** environment using **PowerShell** and **Infrastructure as Code (IaC)** principles. 

The main objective is to automate **Identity and Access Management (IAM)** onboarding processes and enforce **Role-Based Access Control (RBAC)** across dynamic departments.

## 🛠️ Infrastructure Architecture
* **Domain Controller (DC):** Windows Server 2022 Evaluation (Desktop Experience)
* **Client Workstation:** Windows 11 / Windows 10 Enterprise
* **Hypervisor Network:** Oracle VirtualBox isolated **Internal Network (`AD-Lab`)** using static IP routing (`192.168.10.0/24`) and loopback DNS alignment.

## 🚀 Implemented Features

### 1. Automated Onboarding via External Data Ingestion (IaC)
* Created a robust PowerShell automation pipeline that imports employee corporate data from an external `.csv` file (`Import-Csv`).
* **Dynamic Attribute Provisioning:** Automatically parses strings to generate clean, standard corporate identities (`firstname.lastname`), User Principal Names (UPN), and standard descriptions.
* **Security Compliance:** Enforces a strong initial staged password policy forcing user password rotation (`-ChangePasswordAtLogon $true`) on their very first workstation interactive login.

### 2. Role-Based Access Control (RBAC) & Directory Structure
* Built a clean hierarchical deployment by programmatic injection of **Organizational Units (OUs)** splitting root directory structures (`Empresa_Lab`) into business units (`TI`, `RH`, `Vendas`) and centralized core components (`Grupos`).
* Automatically provisions **Global Security Groups** (`GG_DepartmentName`) and manages live nested data membership through strict non-destructive loops (`Add-ADGroupMember`).

### 3. Dynamic Network Drive Mapping via Advanced GPO
* Implemented a **Group Policy Object (GPO)** to map network shared storage seamlessly based on the user's security token context.
* Utilized **Item-level Targeting** within GPO Preferences:
  * Users inside `GG_TI` automatically mount `\\192.168.10.10\TI$` onto drive `Z:`.
  * Users inside `GG_RH` automatically mount `\\192.168.10.10\RH$` onto drive `Y:`.
* Enforced security hardening via hidden administrative share structures (`$`) paired with strict NTFS/SMB access control lists (ACLs).

## 📁 Repository Structure
* `provision_users.ps1`: The core deployment automation script.
* `usuarios.csv`: External spreadsheet data source for batch corporate onboarding tests.

## 🔍 How to Run This Project
1. Set up your Windows Server 2022 Domain Controller on a private VirtualBox internal network.
2. Place the `usuarios.csv` file inside `C:\Compartilhamentos\`.
3. Open **PowerShell ISE (As Administrator)** and execute `provision_users.ps1`.
4. Log into your Windows 11 client machine using one of the newly created accounts to verify the policy enforcement and drive mounts.
