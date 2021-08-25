function LoadVSMSBuildCmd() {
    [bool] $vsSetupInstalled = $null -ne (Get-Command Get-VSSetupINstance -ErrorAction SilentlyContinue)
    if (!$vsSetupInstalled) {
        Write-Verbose "Installing VSSetup module..."
        Install-Module VSSetup -Scope CurrentUser -Force
    }

    $instPath = (Get-VSSetupInstance | Select-VSSetupInstance -Latest -Require Microsoft.Component.MSBuild).InstallationPath
    $batPath = "$instPath\Common7\Tools\VsMSBuildCmd.bat"
    if (Test-Path $batPath -PathType Leaf) {
        $tempFile = [IO.Path]::GetTempFileName()
        $null = cmd.exe /c " `"$batPath`" && set " > $tempFile
        $null = Get-Content $tempFile | Foreach-Object {
            if ($_ -match "^(.*?)=(.*)$") {
                Set-Content "env:\$($matches[1])" $matches[2]
            }
            else {
                $_
            }
        }
        Remove-Item $tempFile
        # Invoke-BatchFile $batPath
        
    }
}

LoadVSMSBuildCmd 

msbuild $args