try {
    $ErrorActionPreference = "Stop";

    Import-Module ".\shared.psm1";
}
catch {
    Write-Host "Failed to load Modules";
    Pause;
    exit 1;
}

function main() {
    if (-not (Test-Path "bypass_update")) {
        PrintLine -Text "Updating, please wait..." -Level $PrintLevel.Info;

        if ($(Update) -ne $true) {
            Pause;
            exit 1;
        }
    }
    else {
        PrintLine -Text "Bypassing Update" -Level $PrintLevel.Info;
    }

    PrintLine -Text "" -Level $PrintLevel.Null;

    if (-not (Test-Path "bypass_verification")) {
        PrintLine -Text "Checking for File integrity, please wait..." -Level $PrintLevel.Info;

        if ($(VerifyIntegrity) -ne $true) {
            Pause;
            exit 1;
        }
    }
    else {
        PrintLine -Text "Bypassing File integrity check" -Level $PrintLevel.Info;
    }

    PrintLine -Text "" -Level $PrintLevel.Null;
    
    Set-Location -Path "./client/";

    Start-Process powershell.exe -ArgumentList "-WindowStyle Minimized -ExecutionPolicy Bypass -File ""./server.ps1""" -NoNewWindow;
    Start-Process "http://localhost:8080/index.html";
}

main;