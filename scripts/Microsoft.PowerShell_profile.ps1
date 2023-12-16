# Declaração de Alias
New-Alias v nvim
New-Alias e explorer


Invoke-Expression (&starship init powershell)
$ENV:STARSHIP_CONFIG = "C:\Users\miguel\.config\starship.toml"


function doc {
    param(
        [string]$caminho,
        [string]$projeto,
        [switch]$v
    )

    $caminho_base = ""

    Switch ($caminho) {
        "xampp"    { $caminho_base = "C:/xampp/htdocs" }
        "laragon"  { $caminho_base = "C:/laragon/www" }
        "github"   { $caminho_base = "$HOME/Documents/Github" }
        default    { $caminho_base = "$HOME/Documents" }
    }

    if ($projeto) {
        $caminho_completo = Join-Path -Path $caminho_base -ChildPath $projeto
        Set-Location -Path $caminho_completo
    } 
    else {
        Set-Location -Path $caminho_base
    }

    if ($v) {
        Get-ChildItem
    }
}


function novo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$nome,

        [Parameter(Mandatory = $true)]
        [string]$conteudo
    )

    try {
        $caminho_completo = Join-Path -Path (Get-Location) -ChildPath $nome

        if (Test-Path $caminho_completo) {
            imprimir_msg "Erro ao criar arquivo!" $true
            Write-Host "Arquivo '$caminho_completo' já existe."
        } 
        else {
            imprimir_msg "Arquivo criado com êxito!" $true
            New-Item -ItemType File -Path $caminho_completo -ErrorAction Stop
            Set-Content -Path $caminho_completo -Value $conteudo
        }
    }
    catch {
        imprimir_msg "Erro ao criar arquivo!" $true
        Write-Host "$_" -ForegroundColor Red
    }
}


function xx {
    param(
        [Parameter(Mandatory = $true)]
        [string]$caminho
    )

    try {
        $item = Get-Item -LiteralPath $caminho -ErrorAction Stop

        if ($item -is [System.IO.DirectoryInfo]) {
            # Obtenha todos os arquivos no diretório e subdiretórios
            $arquivosRemovidos = Get-ChildItem -Path $item.FullName -Recurse | ForEach-Object {
                $_.FullName
                Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }

            # Agora, remova o diretório principal
            Remove-Item -LiteralPath $item.FullName -Force -ErrorAction SilentlyContinue
        } else {
            # Se for um arquivo individual, apenas remova-o
            $arquivosRemovidos = @($item.FullName)
            Remove-Item -LiteralPath $item.FullName -Force -ErrorAction SilentlyContinue
        }

        if ($arquivosRemovidos.Count -gt 0) {
            imprimir_msg "Arquivos excluídos com êxito:" $true
            foreach ($arquivo in $arquivosRemovidos) {
                Write-Host "DEL " -ForegroundColor Red -NoNewline
                Write-Host "$arquivo"
            }
        } 
        else {
            imprimir_msg "Diretório excluído com êxito!" $true
        }
    }
    catch {
        imprimir_msg "Erro ao excluir '$caminho'!" $true
         Write-Host "$_" -ForegroundColor Red
    }
}


function gg {
    param (
        [Parameter(Mandatory = $true)]
        [string]$mensagem
    )

    try {
        Write-Host ""
        Write-Host "COMMIT RÁPIDO" -ForegroundColor Green
        Write-Host "------ ------" -ForegroundColor Green

        imprimir_msg "Status atual do repositório:" $true
        git status -s

        Write-Host ""
        imprimir_msg "Adicionando todos os arquivos alterados para o commit..." $true
        git add .

        imprimir_ok

        imprimir_msg "Realizando o commit..." $true
        git commit -m $mensagem
        Write-Host "    ✅ Commit realizado!" -ForegroundColor Green

        Write-Host ""
        imprimir_msg "Último histórico de commit realizado:" $true
        git log -1

        Write-Host ""
        imprimir_msg "Enviando conteúdo local para o repositório remoto..."$true
        git push
        Write-Host "    ✅ Arquivos enviados!" -ForegroundColor Green
    }
    catch {
        Write-Host "Erro ao realizar commit e push: $_" -ForegroundColor Red
    }
}


function imprimir_msg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$mensagem,

        [Parameter(Mandatory = $true)]
        [bool]$nova_linha
    )

    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "*" -ForegroundColor Green -NoNewline
    Write-Host "] $mensagem" -ForegroundColor Gray -NoNewline
    
    if ($nova_linha) { 
        Write-Host "" 
    }
}


function imprimir_ok {
    Write-Host "OK" -ForegroundColor Green;
    Write-Host ""
}
