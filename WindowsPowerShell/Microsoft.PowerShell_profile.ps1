# no bells
Set-PSReadlineOption -BellStyle None

# Key bindings emulate Vi.
Set-PSReadlineOption -EditMode Vi
Set-PSReadlineOption -ViModeIndicator Cursor

# Better Tab Completion
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# aliases
function q {
    exit
}

function .. {
    cd ..
}

function v {
    try {
        if(Get-Command nvim){
            nvim @Args
        }
    }catch {
        “nvim is not installed”
    }
}

# Prompt
function prompt {
    Write-Host -NoNewline "[" -ForegroundColor Red
    Write-Host -NoNewline $env:UserName -ForegroundColor Yellow
    Write-Host -NoNewline "@" -ForegroundColor Green
    Write-Host -NoNewline $env:computername -ForegroundColor Cyan
    Write-Host -NoNewline "] " -ForegroundColor Red
    Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Magenta
    "$('PS>' * ($nestedPromptLevel + 1)) "
}
