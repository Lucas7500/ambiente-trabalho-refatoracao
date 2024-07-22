# Configura a codificação para UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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
        [Parameter(Mandatory = $false)]
        [string]$nome,

        [Parameter(Mandatory = $false)]
        [string]$conteudo = ""
    )

    Write-Host "╔╗╔┌─┐┬  ┬┌─┐  ╔═╗┬─┐┌─┐ ┬ ┬┬┬  ┬┌─┐" -ForegroundColor Blue
    Write-Host "║║║│ │└┐┌┘│ │  ╠═╣├┬┘│─┼┐│ ││└┐┌┘│ │" -ForegroundColor Blue
    Write-Host "╝╚╝└─┘ └┘ └─┘  ╩ ╩┴└─└─┘└└─┘┴ └┘ └─┘" -ForegroundColor Blue
    Write-Host "v1.0                       @dev-macb" -ForegroundColor White
    Write-Host ""

    if (-not $nome) {
        imprimir_msg "O nome do arquivo não fornecido!" $true "erro"
        imprimir_msg "Operação cancelada!" $true
        return
    }

    try {
        $caminho_completo = Join-Path -Path (Get-Location) -ChildPath $nome

        if (Test-Path $caminho_completo) {
            imprimir_msg "Gerando '$nome' em $(Get-Location)... " $false "aviso"
            imprimir_msg "Arquivo já existe." $true "erro" $false
            imprimir_msg "Operação cancelada!" $true
        } 
        else {
            imprimir_msg "Gerando '$nome' em $(Get-Location)... " $false "aviso"
            New-Item -ItemType File -Path $caminho_completo -ErrorAction Stop | Out-Null
            Set-Content -Path $caminho_completo -Value $conteudo
            imprimir_ok
            imprimir_msg "Arquivo criado com êxito!" $true "sucesso"
        }
    }
    catch [System.UnauthorizedAccessException] {
        imprimir_erro
        imprimir_msg "Você não possui permissão para criar arquivos neste local." $true "erro"
        imprimir_msg "Operação cancelada!" $true
    }
    catch {
        imprimir_msg "Erro ao criar arquivo!" $true "erro"
        Write-Host "$_" -ForegroundColor Red
    }
}


function xx {
    param(
        [Parameter(Mandatory = $true)]
        [string]$caminho
    )

    Write-Host "┌─┐═╗ ╦═╗ ╦┌─┐┬  ┬ ┬┬┬─┐" -ForegroundColor Blue
    Write-Host "├┤ ╔╩╦╝╔╩╦╝│  │  │ ││├┬┘" -ForegroundColor Blue
    Write-Host "└─┘╩ ╚═╩ ╚═└─┘┴─┘└─┘┴┴└─" -ForegroundColor Blue
    Write-Host "v1.0           @dev-macb" -ForegroundColor White
    Write-Host ""

    try {
        $itensRemovidos = @()
        $item = Get-Item -LiteralPath $caminho -ErrorAction Stop        

        if ($item -is [System.IO.DirectoryInfo]) {
            $itensRemovidos = Get-ChildItem -Path $item.FullName -Recurse | ForEach-Object {
                $_.FullName
                if ($_.PSIsContainer) {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                } 
                else {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                }
            }

            Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
            $itensRemovidos += $item.FullName
        } 
        else {
            $itensRemovidos = @($item.FullName)
            Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
        }

        if ($itensRemovidos.Count -gt 0) {
            foreach ($item in $itensRemovidos) {
                imprimir_msg "Excluindo $item... " $false "aviso"
                imprimir_msg "Deletado!" $true "sucesso" $false
            }
        } 
        else {
            imprimir_msg "Nenhum item foi excluído." $true "aviso"
        }
    }
    catch [System.UnauthorizedAccessException] {
        imprimir_msg "Erro de permissão ao excluir '$caminho'!" $true "erro"
        Write-Host "$_" -ForegroundColor Red
    }
    catch {
        imprimir_msg "O sistema não pode encontrar o caminho especificado." $true "erro"
        imprimir_msg "Operação cancelada!" $true
    }
}


function gg {
    param (
        [Parameter(Mandatory = $false)]
        [string]$m,

        [Parameter(Mandatory = $false)]
        [switch]$u,

        [Parameter(Mandatory = $false)]
        [switch]$v = $false
    )

    Write-Host "╔═╗┬┌┬┐  ╔═╗┬┌┬┐┬ ┬┬ ┬┌┐ " -ForegroundColor Blue
    Write-Host "║ ╦│ │   ║ ╦│ │ ├─┤│ │├┴┐" -ForegroundColor Blue
    Write-Host "╚═╝┴ ┴   ╚═╝┴ ┴ ┴ ┴└─┘└─┘" -ForegroundColor Blue
    Write-Host "v1.0            @dev-macb" -ForegroundColor White
    Write-Host ""

    if (-not $m) {
        imprimir_msg "A mensagem do commit não foi fornecida!" $true "erro"
        imprimir_msg "Operação cancelada!" $true
        return
    }
    
    try {
        # Verificar conflitos de merge
        $conflitosMerge = git status 2>&1 | Select-String "Unmerged paths"
        if ($conflitosMerge) {
            imprimir_msg "Status atual do repositório local: " $false
            imprimir_msg "Há conflitos!" $true 'erro' $false
            imprimir_msg "Operação cancelada!" $true
            return
        }

        # Verificar status do repositório
        $status = git status -s
        if ([string]::IsNullOrWhiteSpace($status)) {
            imprimir_msg "Status atual do repositório local: " $false
            imprimir_msg "Sem alteração!" $true "erro" $false
            imprimir_msg "Operação cancelada!" $true
            return
        }

        if ($v) {
            imprimir_msg "Status atual do repositório local:" $true
            git status -s
            Write-Host ""
        }
        
        # Adicionar arquivos alterados
        imprimir_msg "Adicionando todos os arquivos alterados para o commit... " $false
        git add . 2>&1 > $null
        imprimir_ok

        # Realizar commit
        if ($v) {
            imprimir_msg "Realizando o commit... " $true
            git commit -m $m
            Write-Host ""
            imprimir_msg "Último histórico de commit realizado:" $true 'aviso'
            git log -1
            Write-Host ""
        } 
        else {
            imprimir_msg "Realizando o commit... " $false
            git commit -m $m 2>&1 > $null
            if ($LASTEXITCODE -eq 0) {
                imprimir_ok
            } 
            else {
                imprimir_erro
                imprimir_msg "Operação cancelada!" $true
                return
            }
        }

        # Enviar conteúdo para o repositório remoto
        if ($v) {
            imprimir_msg "Enviando conteúdo local para o repositório remoto..." $true 'aviso'
            if ($u) {
                git push --set-upstream origin (git branch --show-current)
            } 
            else {
                git push
            }
        } else {
            imprimir_msg "Enviando conteúdo local para o repositório remoto... " $false 'aviso'
            if ($u) {
                git push --set-upstream origin (git branch --show-current) 2>&1 > $null
            } 
            else {
                git push 2>&1 > $null
            }
            if ($LASTEXITCODE -eq 0) {
                imprimir_ok
            } 
            else {
                imprimir_erro
                imprimir_msg "Operação cancelada!" $true
            }
        }
    } 
    catch {
        imprimir_msg "Erro ao realizar operação!" $true "erro"
        Write-Host "$_"
    }
}



function imprimir_msg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$mensagem,

        [Parameter(Mandatory = $true)]
        [bool]$nova_linha,

        [Parameter(Mandatory = $false)]
        [string]$tipo = 'aviso',

        [Parameter(Mandatory = $false)]
        [bool]$estrela = $true
    )
    function DefinirCorMensagem {
        param (
            [Parameter(Mandatory = $true)]
            [string]$tipo
        )

        switch ($tipo.ToLower()) {
            'sucesso' { return @{ EstrelaCor = [ConsoleColor]::Green; MensagemCor = [ConsoleColor]::Green }}
            'aviso' { return @{ EstrelaCor = [ConsoleColor]::Yellow; MensagemCor = [ConsoleColor]::White }}
            'erro' { return @{ EstrelaCor = [ConsoleColor]::Red; MensagemCor = [ConsoleColor]::Red }}
            default { return @{ EstrelaCor = [ConsoleColor]::White; MensagemCor = [ConsoleColor]::White }}
        }
    }


    $cores = DefinirCorMensagem -tipo $tipo

    if ($estrela) {
        Write-Host "[" -ForegroundColor Gray -NoNewline
        Write-Host "*" -ForegroundColor $cores.EstrelaCor -NoNewline
        Write-Host "] " -ForegroundColor Gray -NoNewline
    }

    Write-Host $mensagem -ForegroundColor $cores.MensagemCor -NoNewline
    
    if ($nova_linha) { 
        Write-Host "" 
    }
}


function imprimir_ok {
    Write-Host "Ok" -ForegroundColor Green;
}

function imprimir_erro {
    Write-Host "Erro!" -ForegroundColor Red;
}