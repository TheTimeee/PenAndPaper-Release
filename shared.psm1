$PrintLevel = @{
    Null    = 0
    Info    = 1
    Warning = 2
    Error   = 3
}

function PrintLine {
    param
    (
        [string] $Text,
        [int] $Level = 0,
        [bool] $NewLine = $true,
        [System.ConsoleColor] $Color = 15
    )
    
    switch ($Level) {
        $PrintLevel.Null {
            Write-Host -NoNewline "" -ForegroundColor White;
        }
        $PrintLevel.Info {
            Write-Host -NoNewline "(INFO) " -ForegroundColor Green;
        }
        $PrintLevel.Warning {
            Write-Host -NoNewline "(WARN) " -ForegroundColor Yellow;
        }
        $PrintLevel.Error {
            Write-Host -NoNewline "(ERROR) " -ForegroundColor Red;
        }
        default {
            Write-Host -NoNewline "(UNKNOWN) " -ForegroundColor Blue;
        }
    }

    if ($NewLine -eq $true) {
        Write-Host $Text -ForegroundColor $Color;
    }
    else {
        Write-Host -NoNewline $Text -ForegroundColor $Color;
    }
}

function Pause {
    Write-Host "Press any key to continue...";
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp");
}

function Update() {
    $ProgressPreference = "SilentlyContinue";

    $protocol = "https";
    $thirdLevel = "raw";
    $secondLevel = "githubusercontent";
    $firstLevel = "com";
    $user = "TheTimeee";
    $repository = "PenAndPaper-Release";
    $branch = "main";

    $qualified = $protocol + "://" + $thirdLevel + "." + $secondLevel + "." + $firstLevel + "/" + $user + "/" + $repository + "/" + $branch + "/";
    
    $manifest = "manifest.ini";
    $output = "update.log";

    $update = $false;
    $version = "0";

    #Log Time
    if (Test-Path $output -PathType Leaf) {
        Add-Content $output "`r`n";
        Add-Content $output "`r`n";
    }
    Add-Content $output ("Date: {0}`r`n" -f (Get-Date));

    #Find current version
    if (Test-Path $manifest -PathType Leaf) {
        PrintLine -Text "Manifest found" -Level $PrintLevel.Info;
        Add-Content $output "Manifest found";
    
        $lines = Get-Content -Path $manifest;

        foreach ($line in $lines) {
            if ($line -match '^\s*;|^(\s*\[.*\]\s*)$') {
                continue;
            }

            $key, $value = $line -split '\s*=\s*', 2;
            if ($key -eq "sVersion") {
                $version = $value;

                PrintLine -Text "Version: $version" -Level $PrintLevel.Info;
                Add-Content $output ("Version: $version");

                break;
            }
        }

        if ($version -eq "0") {
            PrintLine -Text "Failed to find Version" -Level $PrintLevel.Warning;
            Add-Content $output ("Failed to find Version");
        }
    }
    else {
        PrintLine -Text "Failed to find Manifest" -Level $PrintLevel.Warning;
        Add-Content $output "Failed to find Manifest";
    }

    #Downloading server manifest
    try {
        PrintLine -Text "Attempting to download Manifest from Server" -Level $PrintLevel.Info;
        Add-Content $output "Attempting to download Manifest from Server";

        Invoke-WebRequest -Uri "$qualified$manifest" -OutFile "./$($manifest)";

        PrintLine -Text "Downloaded new Manifest successfully" -Level $PrintLevel.Info;
        Add-Content $output "Downloaded new Manifest successfully";
    }
    catch {
        PrintLine -Text "$($_.Exception.Message), exiting" -Level $PrintLevel.Error;
        Add-Content $output "$($_.Exception.Message), exiting";

        #Tolerate failure as client might not have an internet connection
        return $true;
    }

    #Find and compare new version
    if (Test-Path $manifest -PathType Leaf) {
        $found = $false;
        $lines = Get-Content -Path $manifest;

        foreach ($line in $lines) {
            if ($line -match '^\s*;|^(\s*\[.*\]\s*)$') {
                continue;
            }

            $key, $value = $line -split '\s*=\s*', 2;
            if ($key -eq "sVersion") {
                $found = $true;

                if ($version -ne $value) {
                    $update = $true;

                    PrintLine -Text "New Version: $value" -Level $PrintLevel.Info;
                    PrintLine -Text "Require Update" -Level $PrintLevel.Info;
                    Add-Content $output ("New Version: $value");
                    Add-Content $output ("Require Update");
                }
                else {
                    PrintLine -Text "Client is up to date" -Level $PrintLevel.Info;
                    Add-Content $output ("Client is up to date");
                }

                break;
            }
        }

        if ($found -ne $true) {
            PrintLine -Text "New Version not found, exiting" -Level $PrintLevel.Error;
            Add-Content $output ("New Version not found, exiting");

            #Do not tolerate missing version
            return $false;
        }
    }
    else {
        PrintLine -Text "New Manifest not found, exiting" -Level $PrintLevel.Error;
        Add-Content $output "New Manifest not found, exiting";

        #Do not tolerate missing manifest after download
        return $false;
    }
    
    #Creating Directories
    if (Test-Path $manifest -PathType Leaf) {
        $lines = Get-Content -Path $manifest;
        
        foreach ($line in $lines) {
            if ($line -match '^\s*;|^(\s*\[.*\]\s*)$') {
                continue;
            }

            $key, $value = $line -split '\s*=\s*', 2;
            if ($key -eq "sDir") {
                if ($(Test-Path $value -PathType Container) -ne $true) {
                    try {
                        $dir = New-Item -Path "./" -Name "$value" -ItemType "Directory";
                        
                        PrintLine -Text "Created Directory: $dir" -Level $PrintLevel.Info;
                        Add-Content $output ("Created Directory: $dir");
                    }
                    catch {
                        PrintLine -Text "Failed to create Directory: $value, exiting" -Level $PrintLevel.Error;
                        Add-Content $output ("Failed to create Directory: $value, exiting");

                        return $false;
                    }
                }
            }
        }
    }
    else {
        PrintLine -Text "Failed to find Manifest" -Level $PrintLevel.Error;
        Add-Content $output "Failed to find Manifest";

        #Redundant failsafe
        return $false;
    }

    #Update if requested
    if ($update -eq $true) {
        PrintLine -Text "Starting Update" -Level $PrintLevel.Info;
        Add-Content $output ("Starting Update");

        if (Test-Path $manifest -PathType Leaf) {
            $lines = Get-Content -Path $manifest;
            
            foreach ($line in $lines) {
                if ($line -match '^\s*;|^(\s*\[.*\]\s*)$') {
                    continue;
                }
    
                $key, $dir, $name, $hash, $encoding, $eol, $update = $line -split '\s*=\s*|\s*,\s*';
                if ($key -eq "sFile") {
                    if (($update.ToLower() -eq "true") -or ($update.ToLower() -eq "1")) {

                        #Check if File requires Update
                        $identical = $false;
                        if (Test-Path "$dir$name" -PathType Leaf) {
                            if ($hash.ToLower() -eq $($(Get-FileHash -Path "$dir$name" -Algorithm SHA512).Hash).ToLower()) {
                                $identical = $true;

                                PrintLine -Text "$($dir + $name): is up to date" -Level $PrintLevel.Info;
                                Add-Content $output ("$($dir + $name): is up to date");
                            }
                        }

                        #Update File if its not up to date
                        if ($identical -ne $true) {
                            try {
                                Invoke-WebRequest -Uri "$($qualified + $dir + $name)" -OutFile "./$($dir + $name)";

                                #Verify File integrity after download
                                if ($hash.ToLower() -eq $($(Get-FileHash -Path "$dir$name" -Algorithm SHA512).Hash).ToLower()) {
                                    PrintLine -Text "Downloaded: $($qualified + $dir + $name) successfully" -Level $PrintLevel.Info;
                                    Add-Content $output "Downloaded: $($qualified + $dir + $name) successfully";
                                }
                                else {
                                    PrintLine -Text "File: $($qualified + $dir + $name) is corrupted after Download, exiting" -Level $PrintLevel.Error;
                                    Add-Content $output "File: $($qualified + $dir + $name) is corrupted after Download, exiting";

                                    #Do not tolerate corrupted downloads
                                    return $false;
                                }
                            }
                            catch {
                                PrintLine -Text "$($_.Exception.Message), exiting" -Level $PrintLevel.Error;
                                PrintLine -Text "Affected File: $dir$name" -Level $PrintLevel.Error;
                                Add-Content $output "$($_.Exception.Message), exiting";
                                Add-Content $output "Affected File: $dir$name";

                                #Do not tolerate failed download
                                return $false;
                            } 
                        }
                    }
                }
            }
        }
        else {
            PrintLine -Text "Failed to find Manifest" -Level $PrintLevel.Error;
            Add-Content $output "Failed to find Manifest";
    
            #Redundant failsafe
            return $false;
        }

        PrintLine -Text "Finished Update" -Level $PrintLevel.Info;
        Add-Content $output ("Finished Update");
    }

    return $true;
}

function VerifyIntegrity() {
    $ProgressPreference = "SilentlyContinue";
    
    $manifest = "manifest.ini";
    $integrity = $true;

    if (-not (Test-Path $manifest -PathType Leaf)) {
        PrintLine -Text "Failed to find Manifest, exiting" -Level $PrintLevel.Error;

        return $false;
    }

    $lines = Get-Content -Path $manifest;  
    foreach ($line in $lines) {
        if ($line -match '^\s*;|^(\s*\[.*\]\s*)$') {
            continue;
        }
    
        $key, $dir, $name, $hash, $encoding, $eol, $update = $line -split '\s*=\s*|\s*,\s*';
        if ($key -eq "sFile") {
            if (Test-Path "$dir$name" -PathType Leaf) {
                if ($hash.ToLower() -ne $($(Get-FileHash -Path "$dir$name" -Algorithm SHA512).Hash).ToLower()) {
                    PrintLine -Text "File: $($dir + $name) SHA-512 Hash does not match" -Level $PrintLevel.Error;

                    $integrity = $false;
                }
            }
            else {
                PrintLine -Text "File: $($dir + $name) not existing" -Level $PrintLevel.Error;

                $integrity = $false;
            }
        }
    }

    return $integrity;
}

Export-ModuleMember -Variable PrintLevel;

Export-ModuleMember -Function PrintLine;
Export-ModuleMember -Function Pause;
Export-ModuleMember -Function Update;
Export-ModuleMember -Function VerifyIntegrity;