# Executar como Administrador
Set-ExecutionPolicy Bypass -Scope Process -Force
$pastasUsuarios = Get-ChildItem "C:\Users" -Directory | Where-Object {
    $_.Name -notin @('Default', 'Default User', 'Public', 'All Users', 'Administrador', 'unlock' ,'lock' ) -and
    $_.Name -ne $env:USERNAME
}

foreach ($pasta in $pastasUsuarios) {
    try {
        Write-Host "Removendo: $($pasta.FullName)" -ForegroundColor Yellow
        Remove-Item -Path $pasta.FullName -Recurse -Force
    } catch {
        Write-Host "Erro ao remover $($pasta.FullName): $_" -ForegroundColor Red
    }
}




