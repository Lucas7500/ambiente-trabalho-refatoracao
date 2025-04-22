# Geral
function Imprimir-Mensagem {
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
            'sucesso' { return @{ EstrelaCor = [ConsoleColor]::Green; MensagemCor = [ConsoleColor]::Green } }
            'aviso' { return @{ EstrelaCor = [ConsoleColor]::Yellow; MensagemCor = [ConsoleColor]::White } }
            'erro' { return @{ EstrelaCor = [ConsoleColor]::Red; MensagemCor = [ConsoleColor]::Red } }
            default { return @{ EstrelaCor = [ConsoleColor]::White; MensagemCor = [ConsoleColor]::White } }
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

function Texto-Centralizado {
    param (
        [string]$texto
    )

    $tamanhoDoTexto = $texto.Length
    $tamanhoDoEspacamento = [math]::Max(0, [math]::Floor(($TAMANHO_DO_TERMINAL - $tamanhoDoTexto) / 2))
    $textoCentralizado = " " * $tamanhoDoEspacamento + $texto

    Write-Host $textoCentralizado
}

function Texto-Justificado {
    param (
        [string]$textoDireita,
        [string]$textoEsquerda
    )

    $tamanhoDoEspacamento = $TAMANHO_DO_TERMINAL - ($textoDireita.Length + $textoEsquerda.Length)

    if ($tamanhoDoEspacamento -lt 0) {
        Write-Host $textoDireita
        Write-Host $textoEsquerda -ForegroundColor Yellow
        return
    }

    $espacamento = " " * $tamanhoDoEspacamento
    Write-Host "$textoDireita$espacamento$textoEsquerda"
}

# Ferramentas
function Doc {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$repositorio,

        [Parameter(Position = 1)]
        [string]$projeto,

        [switch]$Listar
    )

    Write-Host "╔╦╗╔═╗╔═╗┬ ┬┌┬┐┌─┐┌┐┌┌┬┐┌─┐┌─┐" -ForegroundColor Blue
    Write-Host " ║║║ ║║  │ ││││├┤ │││ │ │ │└─┐" -ForegroundColor Blue
    Write-Host "═╩╝╚═╝╚═╝└─┘┴ ┴└─┘┘└┘ ┴ └─┘└─┘" -ForegroundColor Blue
    Texto-Justificado -textoDireita $POWERSHELL_PROFILE_VERSAO -textoEsquerda $POWERSHELL_PROFILE_DEV
    Write-Host ("═" * $TAMANHO_DO_TERMINAL)

    $caminhos = @{
        "xampp"   = "C:/xampp/htdocs"
        "laragon" = "C:/laragon/www"
        "github"  = "$HOME/Documents/Github"
        "default" = "$HOME/Documents"
    }

    function Show-ErrorMessage {
        param ([string]$message)
        Write-Host $message -ForegroundColor Red
    }

    $caminho_base = if ($caminhos.ContainsKey($repositorio)) { 
        $caminhos[$repositorio] 
    } 
    else { 
        if ($repositorio) {
            Imprimir-Mensagem "Repositório '$repositorio' não encontrado!" $true "erro"
        }
        $caminhos["default"]
    }

    if ($projeto) {
        $caminho_projeto = Join-Path -Path $caminho_base -ChildPath $projeto
        
        if (Test-Path $caminho_projeto) {
            Set-Location -Path $caminho_projeto
            Clear-Host
        } 
        else {
            Show-ErrorMessage "O projeto '$projeto' não existe em '$caminho_base'."
            Set-Location -Path $caminho_base
            if ($Listar) { 
                Get-ChildItem -Directory
                return
            }
            else {
                Imprimir-Mensagem "Localização definida para '$caminho_base'." $true "aviso"
                Imprimir-Mensagem "Operação cancelada." $true "aviso"
            }
        }
    } 
    else {
        Set-Location -Path $caminho_base
        if ($Listar) { 
            Get-ChildItem -Directory
            return
        }
        else {
            Imprimir-Mensagem "Localização definida para $HOME\Documents." $true "aviso"
            Imprimir-Mensagem "Operação cancelada." $true "aviso"
        }
    }
}

function Novo {
    param(
        [Parameter(Mandatory = $false)]
        [string]$nome,

        [Parameter(Mandatory = $false)]
        [string]$conteudo = ""
    )

    Write-Host "╔╗╔╔═╗╦  ╦╔═╗  ┌─┐┬─┐┌─┐ ┬ ┬┬┬  ┬┌─┐" -ForegroundColor Blue
    Write-Host "║║║║ ║╚╗╔╝║ ║  ├─┤├┬┘│─┼┐│ ││└┐┌┘│ │" -ForegroundColor Blue
    Write-Host "╝╚╝╚═╝ ╚╝ ╚═╝  ┴ ┴┴└─└─┘└└─┘┴ └┘ └─┘" -ForegroundColor Blue
    Texto-Justificado -textoDireita $POWERSHELL_PROFILE_VERSAO -textoEsquerda $POWERSHELL_PROFILE_DEV
    Write-Host ("═" * $TAMANHO_DO_TERMINAL)

    if (-not $nome) {
        Imprimir-Mensagem "O nome do arquivo não fornecido!" $true "erro"
        Imprimir-Mensagem "Operação cancelada!" $true
        return
    }

    try {
        $caminho_completo = Join-Path -Path (Get-Location) -ChildPath $nome

        if (Test-Path $caminho_completo) {
            Imprimir-Mensagem "Gerando '$nome' em $(Get-Location)... " $false "aviso"
            Imprimir-Mensagem "Arquivo já existe." $true "erro" $false
            Imprimir-Mensagem "Operação cancelada!" $true
        } 
        else {
            Imprimir-Mensagem "Gerando '$nome' em $(Get-Location)... " $false "aviso"
            New-Item -ItemType File -Path $caminho_completo -ErrorAction Stop | Out-Null
            Set-Content -Path $caminho_completo -Value $conteudo
            Imprimir-Mensagem "Ok" $true "sucesso"
            Imprimir-Mensagem "Arquivo criado com êxito!" $true "sucesso"
        }
    }
    catch [System.UnauthorizedAccessException] {
        Imprimir-Mensagem "Erro" $true "erro"
        Imprimir-Mensagem "Você não possui permissão para criar arquivos neste local." $true "erro"
        Imprimir-Mensagem "Operação cancelada!" $true
    }
    catch {
        Imprimir-Mensagem "Erro ao criar arquivo!" $true "erro"
        Write-Host "$_" -ForegroundColor Red
    }
}

function Xx {
    param(
        [Parameter(Mandatory = $true)]
        [string]$caminho
    )

    Write-Host "┌─┐═╗ ╦═╗ ╦┌─┐┬  ┬ ┬┬┬─┐" -ForegroundColor Blue
    Write-Host "├┤ ╔╩╦╝╔╩╦╝│  │  │ ││├┬┘" -ForegroundColor Blue
    Write-Host "└─┘╩ ╚═╩ ╚═└─┘┴─┘└─┘┴┴└─" -ForegroundColor Blue
    Texto-Justificado -textoDireita $POWERSHELL_PROFILE_VERSAO -textoEsquerda $POWERSHELL_PROFILE_DEV
    Write-Host ("═" * $TAMANHO_DO_TERMINAL)

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
                Imprimir-Mensagem "Excluindo $item... " $false "aviso"
                Imprimir-Mensagem "Deletado!" $true "sucesso" $false
            }
        } 
        else {
            Imprimir-Mensagem "Nenhum item foi excluído." $true "aviso"
        }
    }
    catch [System.UnauthorizedAccessException] {
        Imprimir-Mensagem "Erro de permissão ao excluir '$caminho'!" $true "erro"
        Write-Host "$_" -ForegroundColor Red
    }
    catch {
        Imprimir-Mensagem "O sistema não pode encontrar o caminho especificado." $true "erro"
        Imprimir-Mensagem "Operação cancelada!" $true
    }
}

function Gg {
    param (
        [Parameter(Mandatory = $false)]
        [string]$m,

        [Parameter(Mandatory = $false)]
        [switch]$u,

        [Parameter(Mandatory = $false)]
        [switch]$v = $false
    )

    Write-Host "╔═╗┬┌┬┐   ┬   ╔═╗┬┌┬┐┬ ┬┬ ┬┌┐ " -ForegroundColor Blue
    Write-Host "║ ╦│ │   ┌┼─  ║ ╦│ │ ├─┤│ │├┴┐" -ForegroundColor Blue
    Write-Host "╚═╝┴ ┴   └┘   ╚═╝┴ ┴ ┴ ┴└─┘└─┘" -ForegroundColor Blue
    Texto-Justificado -textoDireita $POWERSHELL_PROFILE_VERSAO -textoEsquerda $POWERSHELL_PROFILE_DEV
    Write-Host ("═" * $TAMANHO_DO_TERMINAL)

    if (-not $m) {
        Imprimir-Mensagem "A mensagem do commit não foi fornecida!" $true "erro"
        Imprimir-Mensagem "Operação cancelada!" $true
        return
    }
    
    try {
        # Verificar conflitos de merge
        $conflitosMerge = git status 2>&1 | Select-String "Unmerged paths"
        if ($conflitosMerge) {
            Imprimir-Mensagem "Status atual do repositório local: " $false
            Imprimir-Mensagem "Há conflitos!" $true 'erro' $false
            Imprimir-Mensagem "Operação cancelada!" $true
            return
        }

        # Verificar status do repositório
        $status = git status -s
        if ([string]::IsNullOrWhiteSpace($status)) {
            Imprimir-Mensagem "Status atual do repositório local: " $false
            Imprimir-Mensagem "Sem alteração!" $true "erro" $false
            Imprimir-Mensagem "Operação cancelada!" $true
            return
        }

        if ($v) {
            Imprimir-Mensagem "Status atual do repositório local:" $true
            git status -s
            Write-Host ""
        }
        
        # Adicionar arquivos alterados
        Imprimir-Mensagem "Adicionando todos os arquivos alterados para o commit... " $false
        git add . 2>&1 > $null
        Imprimir-Mensagem "Ok" $true "sucesso"

        # Realizar commit
        if ($v) {
            Imprimir-Mensagem "Realizando o commit... " $true
            git commit -m $m
            Write-Host ""
            Imprimir-Mensagem "Último histórico de commit realizado:" $true 'aviso'
            git log -1
            Write-Host ""
        } 
        else {
            Imprimir-Mensagem "Realizando o commit... " $false
            git commit -m $m 2>&1 > $null
            if ($LASTEXITCODE -eq 0) {
                Imprimir-Mensagem "Ok" $true "sucesso"
            } 
            else {
                Imprimir-Mensagem "Erro" $true "erro"
                Imprimir-Mensagem "Operação cancelada!" $true
                return
            }
        }

        # Enviar conteúdo para o repositório remoto
        if ($v) {
            Imprimir-Mensagem "Enviando conteúdo local para o repositório remoto..." $true 'aviso'
            if ($u) {
                git push --set-upstream origin (git branch --show-current)
            } 
            else {
                git push
            }
        }
        else {
            Imprimir-Mensagem "Enviando conteúdo local para o repositório remoto... " $false 'aviso'
            if ($u) {
                git push --set-upstream origin (git branch --show-current) 2>&1 > $null
            } 
            else {
                git push 2>&1 > $null
            }
            if ($LASTEXITCODE -eq 0) {
                Imprimir-Mensagem "Ok" $true "sucesso"
            } 
            else {
                Imprimir-Mensagem "Erro" $true "erro"
                Imprimir-Mensagem "Operação cancelada!" $true
            }
        }
    } 
    catch {
        Imprimir-Mensagem "Erro ao realizar operação!" $true "erro"
        Write-Host "$_"
    }
}


# Declarações e definições
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ENV:STARSHIP_CONFIG = "C:\Users\miguel\.config\starship.toml"

$POWERSHELL_PROFILE_VERSAO = "v2.0"
$POWERSHELL_PROFILE_DEV = "@dev-macb"
$TAMANHO_DO_TERMINAL = [console]::WindowWidth

New-Alias v nvim
New-Alias e explorer
Invoke-Expression (&starship init powershell)

Texto-Centralizado " ███▄ ▄███▓ ▄▄▄       ▄████▄   ▄▄▄▄   "
Texto-Centralizado "▓██▒▀█▀ ██▒▒████▄    ▒██▀ ▀█  ▓█████▄ "
Texto-Centralizado "▓██    ▓██░▒██  ▀█▄  ▒▓█    ▄ ▒██▒ ▄██"
Texto-Centralizado "▒██    ▒██ ░██▄▄▄▄██ ▒▓▓▄ ▄██▒▒██░█▀  "
Texto-Centralizado "▒██▒   ░██▒ ▓█   ▓██▒▒ ▓███▀ ░░▓█  ▀█▓"
Texto-Centralizado "░ ▒░   ░  ░ ▒▒   ▓▒█░░ ░▒ ▒  ░░▒▓███▀▒"
Texto-Centralizado "░  ░      ░  ▒   ▒▒ ░  ░  ▒   ▒░▒   ░ "
Texto-Centralizado "░      ░     ░   ▒   ░         ░    ░ "
Texto-Centralizado "       ░         ░  ░░ ░       ░      "
Texto-Centralizado "                     ░              ░ "
