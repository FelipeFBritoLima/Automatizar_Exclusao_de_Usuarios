 Este script remove entradas de perfis de usuário do registro
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList.
#
# ATENÇÃO: Execute este script como Administrador.
# A remoção incorreta de perfis de usuário pode causar instabilidade no sistema.
# Este script remove APENAS as entradas do registro. Para uma remoção completa,
# as pastas de usuário correspondentes em C:\Users também devem ser removidas.

# Define a política de execução para permitir a execução do script no escopo do processo atual.
# Isso é necessário para executar scripts baixados ou criados localmente.
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define o caminho completo para a chave ProfileList no registro.
$profileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

# Obtém o SID (Security Identifier) do usuário atualmente logado.
# Este perfil NÃO será removido para evitar problemas com a sessão atual.
$currentUserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

# Define uma lista de SIDs de sistema conhecidos que NUNCA devem ser removidos.
# Estes são perfis de sistema essenciais para o funcionamento do Windows.
$excludedSystemSIDs = @(
    "S-1-5-18", # Local System
    "S-1-5-19", # Local Service
    "S-1-5-20"  # Network Service
)

# Define uma lista de nomes de usuário cujos perfis NÃO devem ser removidos.
# Isso espelha a lógica de exclusão do seu script de pastas.
# O nome de usuário do usuário atual ($env:USERNAME) também é adicionado para garantir que
# o perfil da sessão atual não seja excluído.
$excludedUsernames = @(
    'Default',
    'Default User',
    'Public',
    'All Users',
    'Administrador',
    'unlock',
    'lock',
    $env:USERNAME # Exclui o perfil do usuário que está executando o script
)

Write-Host "Iniciando a varredura dos perfis de usuário no registro..." -ForegroundColor Cyan

# Obtém todos os sub-itens (SIDs de perfil) dentro da chave ProfileList.
$userProfiles = Get-ChildItem -Path $profileListPath -ErrorAction SilentlyContinue

if ($userProfiles) {
    foreach ($profile in $userProfiles) {
        # O nome do item é o SID do perfil (ex: S-1-5-21-...).
        $profileSID = $profile.PSChildName

        # Verifica se o SID é um SID de sistema excluído.
        if ($excludedSystemSIDs -contains $profileSID) {
            Write-Host "Ignorando perfil de sistema: $($profileSID)" -ForegroundColor DarkGray
            continue # Pula para o próximo perfil
        }

        # Verifica se é o SID do usuário atualmente logado.
        if ($profileSID -eq $currentUserSID) {
            Write-Host "Ignorando perfil do usuário atual: $($profileSID) ($env:USERNAME)" -ForegroundColor DarkGray
            continue # Pula para o próximo perfil
        }

        # Tenta obter o caminho da pasta do perfil (ProfileImagePath).
        # Nem todos os SIDs na ProfileList terão um ProfileImagePath válido (ex: alguns SIDs de grupos).
        $profileImagePath = (Get-ItemProperty -Path $profile.PSPath -Name ProfileImagePath -ErrorAction SilentlyContinue).ProfileImagePath

        # Se um ProfileImagePath for encontrado, extrai o nome de usuário.
        if ($profileImagePath) {
            # Extrai o nome de usuário do caminho da pasta (ex: C:\Users\NomeUsuario -> NomeUsuario).
            $username = Split-Path -Path $profileImagePath -Leaf

            # Verifica se o nome de usuário está na lista de exclusão.
            if ($excludedUsernames -contains $username) {
                Write-Host "Ignorando perfil de usuário excluído: $($profileSID) (Pasta: $profileImagePath)" -ForegroundColor DarkGray
                continue # Pula para o próximo perfil
            }
        } else {
            # Se não há ProfileImagePath, pode ser um perfil órfão ou um SID não mapeado para uma pasta de usuário.
            # Decida se deseja remover esses. Por segurança, este script os considera para remoção
            # se não forem SIDs de sistema ou do usuário atual.
            Write-Host "Perfil sem ProfileImagePath claro: $($profileSID). Será considerado para remoção." -ForegroundColor Yellow
        }

        # Se chegou até aqui, o perfil não está na lista de exclusão e é um candidato para remoção.
        try {
            Write-Host "Removendo entrada do registro para o perfil: $($profileSID) (Pasta: $($profileImagePath -replace '%SystemRoot%', $env:SystemRoot))" -ForegroundColor Yellow
            # Remove a chave do registro correspondente ao SID do perfil.
            Remove-Item -Path $profile.PSPath -Recurse -Force -ErrorAction Stop
            Write-Host "Removido com sucesso: $($profileSID)" -ForegroundColor Green
        } catch {
            Write-Host "Erro ao remover $($profileSID): $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Nenhum perfil de usuário encontrado na chave $profileListPath." -ForegroundColor Yellow
}

Write-Host "Processo de remoção de perfis do registro concluído." -ForegroundColor Cyan
