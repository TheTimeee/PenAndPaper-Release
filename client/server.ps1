$PrintLevel = @{
    Null    = 0
    Info    = 1
    Warning = 2
    Error   = 3
}

function PrintLine {
    param
    (
        [string] $text,
        [int] $level = 0,
        [bool] $newLine = $true,
        [System.ConsoleColor] $color = 15
    )
    
    switch ($level) {
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

    if ($newLine -eq $true) {
        Write-Host $text -ForegroundColor $color;
    }
    else {
        Write-Host -NoNewline $text -ForegroundColor $color;
    }
}

function Pause {
    Write-Host "Press any key to continue...";
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp");
}

function IsRootViolated {
    param
    (
        [string]$path
    )

    try {
        #Define Root Dir
        $root = "./";

        #Check if Path exists as is
        if ($(Test-Path $path) -eq $false) {
            $path = Split-Path -Path $path;
        }

        #Check if path ends with '/' and add if it does not to normalize
        if ($path.Length -gt 0) {
            if ($path[$path.Length - 1] -ne '/') {
                $path += '/';
            }
        }

        #Resolve relative paths to absoloute paths
        $path = [System.IO.Path]::GetFullPath($path);
        $root = [System.IO.Path]::GetFullPath($root);

        #Check if Root is greater than path, if yes it must be a root violation
        if ($root.Length -gt $path.Length) {
            return $true;
        }

        #Check if path is identical up to root end
        for ($i = 0; $i -lt $root.Length; $i++) {
            if ($root[$i] -ne $path[$i]) {
                return $true;
            }
        }
    
        return $false;
    }
    catch {
        PrintLine -text "Failed to resolve IsRootViolated" -level $PrintLevel.Error -newLine $true

        return $true;
    }
}

function FileExtensionToMimeType {
    param
    (
        [string]$extension
    )

    switch ($extension) {
        ".txt" {
            return "text/plain";
        }
        ".html" {
            return "text/html";
        }
        ".xml" {
            return "text/xml";
        }
        ".ini" {
            return "text/plain";
        }
        ".csv" {
            return "text/csv";
        }
        ".png" {
            return "image/png";
        }
        ".jpg" {
            return "image/jpeg";
        }
        ".jpeg" {
            return "image/jpeg";
        }
        ".gif" {
            return "image/gif";
        }
        ".bmp" {
            return "image/bmp";
        }
        ".tiff" {
            return "image/tiff";
        }
        ".webp" {
            return "image/webp";
        }
        ".ico" {
            return "image/x-icon";
        }
        ".mp3" {
            return "audio/mpeg";
        }
        ".aac" {
            return "audio/aac";
        }
        ".wav" {
            return "audio/wav";
        }
        ".ogg" {
            return "audio/ogg";
        }
        ".flac" {
            return "audio/flac";
        }
        ".mp4" {
            return "video/mp4";
        }
        ".webm" {
            return "video/webm";
        }
        ".avi" {
            return "video/x-msvideo";
        }
        ".mkv" {
            return "video/x-matroska";
        }
        ".mov" {
            return "video/quicktime";
        }
        ".js" {
            return "application/javascript";
        }
        ".mjs" {
            return "application/javascript";
        }
        ".json" {
            return "application/json";
        }
        ".pdf" {
            return "application/pdf";
        }
        ".wasm" {
            return "application/wasm";
        }
        default {
            return $null;
        }
    }

    return $null;
}

function IsUploadWhitelistViolated {
    param
    (
        [string]$extension
    )

    switch ($extension) {
        ".sav" {
            return $false;
        }
        ".ini" {
            return $false;
        }
        ".pnp" {
            return $false;
        }
        default {
            return $true;
        }
    }

    return $true;
}

function EntryPoint() {
    $listener = New-Object System.Net.HttpListener;
    $listener.Prefixes.Add("http://localhost:8080/");
    $listener.Prefixes.Add("http://127.0.0.1:8080/");
    $listener.Prefixes.Add("http://[::1]:8080/");

    #Try to start server and end exectution if a Webserver already runs
    try {
        $listener.Start();

        PrintLine -text "Server is listening at address: " -level $PrintLevel.Info -newLine $false;
        PrintLine -text "http://localhost:8080/" -level $PrintLevel.Null -color Green -newLine $false;
        PrintLine -text " Press Ctrl+Left to open." -level $PrintLevel.Null;
        PrintLine -text "Root Directory: " -level $PrintLevel.Info -color White -newLine $false;
        PrintLine -text "$(Get-Location)" -level $PrintLevel.Null -color Green -newLine $true;
        PrintLine -text "Keep this open for the Pen and Paper Client to work." -level $PrintLevel.Info;
        PrintLine -text "" -level $PrintLevel.Null -newLine $true;
    }
    catch [System.Net.HttpListenerException] {
        return 0;
    }
    
    #Enter main loop
    while ($true) {
        try {
            #Retrieve relevant fields
            $context = $listener.GetContext();
            $request = $context.Request;
            $response = $context.Response;
            $url = $request.Url.LocalPath.TrimStart("/");
            $method = $request.HttpMethod;
            $ip = $request.RemoteEndPoint.Address.ToString();
            $time = Get-Date;

            #If no file is requested default to index.html
            if ($url.Length -le 0) {
                $url = "index.html";
            }

            #Add CORS origins
            $response.Headers.Add("Access-Control-Allow-Origin", "http://localhost:8080, http://127.0.0.1:8080, http://[::1]:8080, http://localhost:9090, http://127.0.0.1:9090, http://[::1]:9090, https://code.jquery.com");

            #Add CORS headers
            $response.Headers.Add("Cross-Origin-Opener-Policy", "same-origin");
            $response.Headers.Add("Cross-Origin-Resource-Policy", "same-origin");
            $response.Headers.Add("Cross-Origin-Embedder-Policy", "require-corp");

            #Add Requested file's mime type if applicable
            $requestExtension = [System.IO.Path]::GetExtension($url);
            $requestType = FileExtensionToMimeType -extension $requestExtension;
            if ($null -ne $requestType) {
                $response.Headers.Add("Content-Type", $requestType);
            }
            
            #Handle different request types
            if ($method -eq "GET") {
                if ((IsRootViolated $("./" + $url)) -eq $true) {
                    $response.StatusCode = 403;
            
                    PrintLine -text "{$($time)} Client[$($ip)] Requested resource outside of Root, Forbidden(Access denied) " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $url -level $PrintLevel.Null -color Red;
                }
                elseif (Test-Path $url -PathType Leaf) {
                    $response.StatusCode = 200;

                    $content = [System.IO.File]::ReadAllBytes($url);
                    
                    PrintLine -text "{$($time)} Client[$($ip)] Requested resource " -level $PrintLevel.Info -newLine $false;
                    PrintLine -text $url -level $PrintLevel.Null -color Green;
    
                    $response.OutputStream.Write($content, 0, $content.Length);
                }
                elseif (Test-Path $url -PathType Container) {
                    $response.StatusCode = 200;
                    $response.ContentType = "application/json";

                    $content = "[";
                    $first = $false;
                    foreach ($file in $(Get-ChildItem -Path $url)) {
                        if ($first -eq $true) {
                            $content += ", ";
                        }
                        else {
                            $first = $true;
                        }

                        $content += '"' + $file + '"';
                    }
                    $content += "]";

                    $prepared = [System.Text.Encoding]::UTF8.GetBytes($content);

                    PrintLine -text "{$($time)} Client[$($ip)] Requested contents of directory " -level $PrintLevel.Info -newLine $false;
                    PrintLine -text $url -level $PrintLevel.Null -color Green;

                    $response.OutputStream.Write($prepared, 0, $prepared.Length);
                }
                else {
                    $response.StatusCode = 404;
            
                    PrintLine -text "{$($time)} Client[$($ip)] Failed to load resource " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $url -level $PrintLevel.Null -color Red;
                }
            }
            elseif ($method -eq "POST") {
                $file = "";

                $filePath = $request.Headers["File-Path"];
                $fileName = $request.Headers["File-Name"];
                $fileExtension = $request.Headers["File-Extension"];

                if ($null -eq $filePath) { $filePath = "./"; }
                if ($filePath.Length -le 0) { $filePath = "./"; }
                $file += $filePath;

                if ($null -ne $fileName) { $file += $fileName; }
                if ($null -ne $fileExtension) { $file += $fileExtension; }

                if (($null -eq $fileName) -or ($null -eq $fileExtension)) {
                    $response.StatusCode = 403;

                    PrintLine -text "{$($time)} Client[$($ip)] Requested to write resource without file name or extension " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $file -level $PrintLevel.Null -color Red;
                }
                if (($fileName.Length -le 0) -or ($fileExtension.Length -le 0)) {
                    $response.StatusCode = 403;

                    PrintLine -text "{$($time)} Client[$($ip)] Requested to write resource without file name or extension " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $file -level $PrintLevel.Null -color Red;
                }
                elseif ((IsRootViolated $("./" + $file)) -eq $true) {
                    $response.StatusCode = 403;
            
                    PrintLine -text "{$($time)} Client[$($ip)] Requested to write resource outside of Root, Forbidden(Access denied) " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $file -level $PrintLevel.Null -color Red;
                }
                elseif ((IsUploadWhitelistViolated $fileExtension) -eq $true) {
                    $response.StatusCode = 403;
            
                    PrintLine -text "{$($time)} Client[$($ip)] Requested to write resource that violates file extension whitelist, Forbidden(Access denied) " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $file -level $PrintLevel.Null -color Red;
                }
                elseif (Test-Path $filePath) {
                    $response.StatusCode = 200;
                    
                    PrintLine -text "{$($time)} Client[$($ip)] Requested to write resource " -level $PrintLevel.Info -newLine $false;
                    PrintLine -text $file -level $PrintLevel.Null -color Green;

                    $stream = $request.InputStream;
                    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8);
                    $data = $reader.ReadToEnd();
                    $reader.Close();

                    [System.IO.File]::WriteAllText($file, $data);
                }
                else {
                    $response.StatusCode = 404;
            
                    PrintLine -text "{$($time)} Client[$($ip)] Failed to write resource, target directory does not exist " -level $PrintLevel.Warning -newLine $false;
                    PrintLine -text $file -level $PrintLevel.Null -color Red;
                }
            }
            else {
                $response.StatusCode = 405;
    
                PrintLine -text "{$($time)} Client[$($ip)] Unsupported request type " -level $PrintLevel.Warning -newLine $false;
                PrintLine -text $method -level $PrintLevel.Null -color Red;
            }

            #Close Request
            $response.Close();
        }
        catch {
            #Error handling always returns 403, Forbidden
            $response.StatusCode = 403;
            $response.Close();
        
            PrintLine -text $_.Exception.Message -level $PrintLevel.Error;
        }
    }

    $listener.Stop();
    $listener.Close();

    return 0;
}

try {
    if ($null -ne $($MyInvocation.MyCommand.Path)) {
        Set-Location -Path "$((Split-Path -Path $MyInvocation.MyCommand.Path -Parent))";
        
        EntryPoint;
    }
    else {
        PrintLine -text "Failed to find script location. Terminating." -level $PrintLevel.Error -newLine $true;
        Pause;

        Exit;
    }
}
catch {
    PrintLine -text $_.Exception.Message -level $PrintLevel.Error;
    Pause;

    Exit;
}