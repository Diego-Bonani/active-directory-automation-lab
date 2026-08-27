# 1. Definir o caminho do arquivo CSV externo
$PathCSV = "C:\Compatilhamentos\usuarios.csv"

# Verificar se o arquivo realmente existe antes de continuar
if (-not (Test-Path $PathCSV)) {
    Write-Error "Arquivo CSV não encontrado em: $PathCSV. Crie o arquivo primeiro."
    exit
}

# 2. Importar os dados do CSV para a memória
$Funcionarios = Import-Csv -Path $PathCSV -Delimiter ","

# 3. Pegar as informações do domínio atual automaticamente
$DomainDN = (Get-ADDomain).DistinguishedName
$OU_Raiz_Nome = "Empresa_Lab"

# 4. Criar a Unidade Organizacional (OU) Principal se não existir
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OU_Raiz_Nome'")) {
    New-ADOrganizationalUnit -Name $OU_Raiz_Nome -Path $DomainDN
    Write-Host "OU Principal '$OU_Raiz_Nome' criada com sucesso!" -ForegroundColor Green
}
$OU_Raiz_Path = "OU=$OU_Raiz_Nome,$DomainDN"

# 5. Criar a sub-OU 'Grupos' se não existir
$OU_Grupos_Nome = "Grupos"
$OU_Grupos_Path = "OU=$OU_Grupos_Nome,$OU_Raiz_Path"
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OU_Grupos_Nome'" -SearchBase $OU_Raiz_Path)) {
    New-ADOrganizationalUnit -Name $OU_Grupos_Nome -Path $OU_Raiz_Path
    Write-Host "Sub-OU '$OU_Grupos_Nome' criada para armazenar os Grupos de Segurança." -ForegroundColor Green
}

# 6. Criar uma senha padrão segura (Exige alteração no 1º login)
$SenhaPadrao = ConvertTo-SecureString "Senha@Lab2026" -AsPlainText -Force

# 7. Loop para ler cada linha do arquivo CSV
foreach ($Func in $Funcionarios) {
    
    $DeptoNome = $Func.Depto
    $OU_Depto_Path = "OU=$DeptoNome,$OU_Raiz_Path"
    $GrupoNome = "GG_$DeptoNome"
    
    # A. Criar a sub-OU do Departamento se não existir
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$DeptoNome'" -SearchBase $OU_Raiz_Path)) {
        New-ADOrganizationalUnit -Name $DeptoNome -Path $OU_Raiz_Path
        Write-Host "Sub-OU '$DeptoNome' criada para os usuários." -ForegroundColor Green
    }

    # B. Criar o Grupo de Segurança do Departamento se não existir
    if (-not (Get-ADGroup -Filter "Name -eq '$GrupoNome'")) {
        New-ADGroup -Name $GrupoNome `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $OU_Grupos_Path `
                    -Description "Grupo de Segurança Global para o departamento de $DeptoNome"
        Write-Host "Grupo de Segurança '$GrupoNome' criado com sucesso!" -ForegroundColor Green
    }

    # C. Gerar propriedades do usuário (padrão: nome.sobrenome)
    $SamAccountName = "$($Func.Nome.ToLower()).$($Func.Sobrenome.ToLower())"
    $UserPrincipalName = "$SamAccountName@$((Get-ADDomain).DNSRoot)"
    $DisplayName = "$($Func.Nome) $($Func.Sobrenome)"

    # D. Criar ou atualizar o usuário no Active Directory
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'")) {
        New-ADUser -Name $DisplayName `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UserPrincipalName `
                   -DisplayName $DisplayName `
                   -GivenName $Func.Nome `
                   -Surname $Func.Sobrenome `
                   -Department $DeptoNome `
                   -Path $OU_Depto_Path `
                   -AccountPassword $SenhaPadrao `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true

        Write-Host "Usuário criado via CSV: $DisplayName ($SamAccountName)" -ForegroundColor Cyan
    } else {
        Set-ADUser -Identity $SamAccountName -Department $DeptoNome
        Write-Host "Usuário $SamAccountName já validado no sistema." -ForegroundColor Yellow
    }

    # E. Vincular o Usuário do CSV ao seu respectivo Grupo (RBAC)
    $IsMember = Get-ADGroupMember -Identity $GrupoNome | Where-Object { $_.SamAccountName -eq $SamAccountName }
    if (-not $IsMember) {
        Add-ADGroupMember -Identity $GrupoNome -Members $SamAccountName
        Write-Host "-> Usuário $SamAccountName adicionado ao grupo $GrupoNome." -ForegroundColor Blue
    }
}
