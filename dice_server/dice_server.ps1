$PrintLevel = @{
    Null    = 0
    Info    = 1
    Warning = 2
    Error   = 3
}

function PrintLine
{
    param
    (
        [string] $text,
        [int] $level = 0,
        [bool] $newLine = $true,
        [System.ConsoleColor] $color = 15
    )
    
    switch ($level)
    {
        $PrintLevel.Null
        {
            Write-Host -NoNewline "" -ForegroundColor White;
        }
        $PrintLevel.Info
        {
            Write-Host -NoNewline "(INFO) " -ForegroundColor Green;
        }
        $PrintLevel.Warning
        {
            Write-Host -NoNewline "(WARN) " -ForegroundColor Yellow;
        }
        $PrintLevel.Error
        {
            Write-Host -NoNewline "(ERROR) " -ForegroundColor Red;
        }
        default
        {
            Write-Host -NoNewline "(UNKNOWN) " -ForegroundColor Blue;
        }
    }

    if ($newLine -eq $true)
    {
        Write-Host $text -ForegroundColor $color;
    }
    else
    {
        Write-Host -NoNewline $text -ForegroundColor $color;
    }
}

function Pause
{
    Write-Host "Press any key to continue...";
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp");
}

function CompileJS()
{
    $scripts = @(
        "./script/shared/DiceBot.js"
    );

    try
    {
        for ($i = 0; $i -lt $scripts.Count; $i++)
        {
            $script = Get-Content -Raw -Path "$($scripts[$i])" -ErrorAction SilentlyContinue;

            $script = $script -replace '(static\b)', '$1 function';
            $script = $script -replace '\blet(?=\s)', 'var';

            Add-Type -Language JScript -TypeDefinition $script -ErrorAction SilentlyContinue;

            PrintLine -text "Compilation of: " -level $PrintLevel.Info -newLine $false;
            PrintLine -text "$($scripts[$i])" -level $PrintLevel.Null -color Green -newLine $false;
            PrintLine -text " was successful." -level $PrintLevel.Null -newLine $true;
        }

        PrintLine -text "" -level $PrintLevel.Null -newLine $true;
    }
    catch
    {
        PrintLine -text "Compilation of: " -level $PrintLevel.Error -newLine $false;
        PrintLine -text "$($scripts[$i])" -level $PrintLevel.Null -color Green -newLine $false;
        PrintLine -text " failed." -level $PrintLevel.Null -newLine $true;
        PrintLine -text "" -level $PrintLevel.Null -newLine $true;

        Pause;

        Exit;
    }
}

function EntryPoint()
{
    #Precomile and load shared JS dependencies
    CompileJS;

    $listener = New-Object System.Net.HttpListener;
    $listener.Prefixes.Add("http://*:9090/");

    #Try to start server and end exectution if a Webserver already runs
    try
    {
        $listener.Start();

        PrintLine -text "Server is listening at port: " -level $PrintLevel.Info -newLine $false;
        PrintLine -text "9090" -level $PrintLevel.Null -color Green -newLine $true;
        PrintLine -text "This server will respond to ANY request." -level $PrintLevel.Info -newLine $true;
        PrintLine -text "THIS SERVER RUNS WITH ADMINISTRATOR PRIVILEGES UNDER: " -level $PrintLevel.Info -color White -newLine $false;
        PrintLine -text "$(Get-Location)" -level $PrintLevel.Null -color Red -newLine $true;
        PrintLine -text "" -level $PrintLevel.Null -newLine $true;
    }
    catch [System.Net.HttpListenerException]
    {
        PrintLine -text "Failed to bind to port: " -level $PrintLevel.Error -newLine $false;
        PrintLine -text "9090" -level $PrintLevel.Null -color Red -newLine $true;
        PrintLine -text "Rerun the server with Administrator privileges and only run one instance per machine." -level $PrintLevel.Error -newLine $true;

        Pause;

        return 0;
    }

    # Creating a client ip and timestamp hashtable
    $clients = @{ };
    
    #Enter main loop
    while ($true)
    {
        try
        {
            #Retrieve relevant fields
            $context = $listener.GetContext();
            $request = $context.Request;
            $response = $context.Response;
            #$url = $request.Url.LocalPath.TrimStart("/");
            $method = $request.HttpMethod;
            $ip = $request.RemoteEndPoint.Address.ToString();
            $time = Get-Date;

            #Allow any CORS origin and headers
            $response.Headers.Add("Access-Control-Allow-Origin", "*");
            $response.Headers.Add("Access-Control-Allow-Headers", "*");

            #Add CORS headers
            $response.Headers.Add("Cross-Origin-Opener-Policy", "same-origin");
            $response.Headers.Add("Cross-Origin-Resource-Policy", "same-origin");
            $response.Headers.Add("Cross-Origin-Embedder-Policy", "require-corp");

            #Handle specialized GET Request, reject all others
            if ($method -eq "GET")
            {
                if ($null -ne $request.Headers["Dice-Connect"])
                {
                    $response.StatusCode = 200;

                    PrintLine -text "{$($time)} Client[$($ip)] requested to connect." -level $PrintLevel.Info -newLine $true;
                    PrintLine -text "" -level $PrintLevel.Null;
                }
                elseif ($null -ne $request.Headers["Dice-Skill"])
                {
                    $response.StatusCode = 200;

                    $clientDeltaNow = $time.Ticks / 10000000;
                    $clientDeltaLast = if ($null -ne $clients[$ip]) { $clients[$ip] } else { 0 };
                    $clientDeltaMin = 0.5;
                    $clients[$ip] = $clientDeltaNow;

                    if ($clientDeltaLast + $clientDeltaMin -gt $clientDeltaNow)
                    {
                        $result = "You are being rate limited, please wait at least $clientDeltaMin seconds.";

                        $prepared = [System.Text.Encoding]::UTF8.GetBytes($result);
                        $response.OutputStream.Write($prepared, 0, $prepared.Length);
                    }
                    else
                    {
                        $name = $request.QueryString["Dice-Name"];
                        $intention = $request.QueryString["Dice-Intention"];
                        $amount = $request.QueryString["Dice-Amount"];
                        $rolls = $request.QueryString["Dice-Rolls"];
                        $signet = $request.QueryString["Dice-Signet"];
                        $ewhaja = $request.QueryString["Signet-EwHaja"];

                        #Check for null values, then validate input and force boundaries
                        if ($null -eq $name) { $response.StatusCode = 403; } else { if ($name.Length -gt 256) { $name = $name.SubString(0, 256); } }
                        if ($null -eq $intention) { $response.StatusCode = 403; } else { if ($intention.Length -gt 256) { $intention = $intention.SubString(0, 256); } }
                        if ($null -eq $amount) { $response.StatusCode = 403; } else { if ([int]::TryParse($amount, [ref]$null) -eq $true) { $amount = [int]$amount } else { $amount = 0 }; }
                        if ($null -eq $rolls) { $response.StatusCode = 403; } else { if ([int]::TryParse($rolls, [ref]$null) -eq $true) { $rolls = [int]$rolls } else { $rolls = 0 }; }
                        if ($null -eq $signet) { $response.StatusCode = 403; } else { if ([int]::TryParse($signet, [ref]$null) -eq $true) { $signet = [int]$signet } else { $signet = 0 }; }
                        if ($null -eq $ewhaja) { $response.StatusCode = 403; } else { if ([int]::TryParse($ewhaja, [ref]$null) -eq $true) { $ewhaja = [int]$ewhaja } else { $ewhaja = 0 }; }
                
                        if ($response.StatusCode -eq 200)
                        {
                            #sName, sIntention, iDice, iCycles, iSignet, sResults, iSuccess, iFailure, iSum, iCritFailure, bEwHaja
                            $container = [DiceBot]::Roll($name, $intention, $amount, $rolls, $signet, "", 0, 0, 0, 0, $ewhaja);

                            PrintLine -text "" -level $PrintLevel.Null;
                            PrintLine -text "" -level $PrintLevel.Null;

                            PrintLine -text "{$($time)} Client[$($ip)] requested to roll:" -level $PrintLevel.Info -newLine $true;
                            PrintLine -text "" -level $PrintLevel.Null;

                            PrintLine -text "Name: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[0])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Intention: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[1])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "-----------------------------" -level $PrintLevel.Null -newLine $true;
                            PrintLine -text "Amount: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[2])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Rolls: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[3])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Signet: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[4])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Ew'Haja's Signet: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[10])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "-----------------------------" -level $PrintLevel.Null -newLine $true;
                            PrintLine -text "Result: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[5])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Success: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[6])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Failures: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[7])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Sum: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[8])" -level $PrintLevel.Null -color Green -newLine $true;
                            PrintLine -text "Critical Failure: " -level $PrintLevel.Null -newLine $false;
                            PrintLine -text "$($container[9])" -level $PrintLevel.Null -color Green -newLine $true;

                            $result = "IDD_ROLL_DICE: $($container[2])`n";
                            $result += "IDD_ROLL_CYCLES: $($container[3])`n";
                            $result += "IDD_ROLL_SIGNET: $($container[4])`n";
                            $result += if ($ewhaja) { "IDD_ROLL_EWHAJA`n" } else { "" };
                            $result += "-----------------------------`n";
                            $result += "IDD_ROLL_RESULT: $($container[5])`n";
                            $result += "IDD_ROLL_SUCCESS: $($container[6])`n";
                            $result += "IDD_ROLL_FAILURE: $($container[7])`n";
                            $result += "IDD_ROLL_SUM: $($container[8])`n";
                            $result += "IDD_ROLL_CRIT: $($container[9])";

                            $prepared = [System.Text.Encoding]::UTF8.GetBytes($result);
                            $response.OutputStream.Write($prepared, 0, $prepared.Length);
                        }
                        else
                        {
                            PrintLine -text "{$($time)} Client[$($ip)] submitted a malformed request: Failed to fetch parameters." -level $PrintLevel.Error -newLine $true;
                        }
                    }
                }
                else
                {
                    $response.StatusCode = 403;

                    PrintLine -text "{$($time)} Client[$($ip)] submitted a malformed request: No Valid Header." -level $PrintLevel.Error -newLine $true;
                }
            }
            elseif ($method -eq "OPTIONS") #Allow any preflight request
            {
                $response.StatusCode = 200;
            }
            else
            {
                $response.StatusCode = 405;
    
                PrintLine -text "{$($time)} Client[$($ip)] Unsupported request type " -level $PrintLevel.Warning -newLine $false;
                PrintLine -text $method -level $PrintLevel.Null -color Red;
            }

            #Close Request
            $response.Close();
        }
        catch
        {
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

try
{
    if ($null -ne $($MyInvocation.MyCommand.Path))
    {
        Set-Location -Path "$((Split-Path -Path $MyInvocation.MyCommand.Path -Parent) + '\..\client')";

        EntryPoint;
    }
    else
    {
        PrintLine -text "Failed to find script location. Terminating." -level $PrintLevel.Error -newLine $true;
        Pause;

        Exit;
    }
}
catch
{
    PrintLine -text $_.Exception.Message -level $PrintLevel.Error;
    Pause;

    Exit;
}