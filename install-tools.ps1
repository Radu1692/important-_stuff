#Requires -RunAsAdministrator

$DownloadDir = "$env:TEMP\ToolInstall"
New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null

# DBEaver
Write-Host "Downloading DBEaver..."
$DBeaverInstaller = "$DownloadDir\dbeaver-ce-26.1.0-windows-x86_64.exe"

Invoke-WebRequest `
    -Uri "https://github.com/dbeaver/dbeaver/releases/download/26.1.0/dbeaver-ce-26.1.0-windows-x86_64.exe" `
    -OutFile $DBeaverInstaller

Write-Host "Installing DBEaver..."
Start-Process `
    -FilePath $DBeaverInstaller `
    -ArgumentList "/S", "/allusers" `
    -Wait

# PostgreSQL JDBC driver
Write-Host "Downloading PostgreSQL JDBC driver..."
$DriverDirectory = "C:\ProgramData\DBeaver\drivers\PostgreSQL"
$PostgresDriver = "$DriverDirectory\postgresql-42.7.11.jar"

New-Item -ItemType Directory -Path $DriverDirectory -Force | Out-Null

Invoke-WebRequest `
    -Uri "https://github.com/pgjdbc/pgjdbc/releases/download/REL42.7.11/postgresql-42.7.11.jar" `
    -OutFile $PostgresDriver

Write-Host "PostgreSQL JDBC driver downloaded to:"
Write-Host $PostgresDriver

Write-Host ""
Write-Host "Manual DBEaver configuration required:"
Write-Host "1. Open DBEaver."
Write-Host "2. Open Database > Driver Manager."
Write-Host "3. Select PostgreSQL and click Edit."
Write-Host "4. Open the Libraries tab."
Write-Host "5. Delete these libraries:"
Write-Host "   net.postgis:postgis-jdbc:RELEASE [2.5.0]"
Write-Host "   org.postgresql:postgresql:RELEASE [42.7.11]"
Write-Host "   com.github.waffle:waffle-jna:RELEASE [3.5.1]"
Write-Host "6. Click Add File."
Write-Host "7. Select: $PostgresDriver"
Write-Host "8. Click OK."

# Start DBEaver
$DBeaverExe = "${env:ProgramFiles}\DBeaver\dbeaver.exe"

if (Test-Path $DBeaverExe) {
    Start-Process $DBeaverExe
} else {
    Write-Warning "DBEaver executable was not found at $DBeaverExe"
}


# Create temp download directory
$DownloadDir = "$env:TEMP\ToolInstall"
New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null

Write-Host "Downloading Freelens..."
$FreelensExe = "$DownloadDir\Freelens-1.9.0-windows-amd64.exe"
Invoke-WebRequest -Uri "https://github.com/freelensapp/freelens/releases/download/v1.9.0/Freelens-1.9.0-windows-amd64.exe" -OutFile $FreelensExe

Write-Host "Installing Freelens..."
Start-Process -FilePath $FreelensExe -Wait

Write-Host "Downloading Azure CLI..."
$AzCliMsi = "$DownloadDir\azure-cli-2.87.0.msi"
Invoke-WebRequest -Uri "https://github.com/Azure/azure-cli/releases/download/azure-cli-2.87.0/azure-cli-2.87.0.msi" -OutFile $AzCliMsi

Write-Host "Installing Azure CLI..."
Start-Process "msiexec.exe" -ArgumentList "/i `"$AzCliMsi`" /qn" -Wait

Write-Host "Downloading kubelogin..."
$KubeloginZip = "$DownloadDir\kubelogin-win-amd64.zip"
Invoke-WebRequest -Uri "https://github.com/Azure/kubelogin/releases/download/v0.2.19/kubelogin-win-amd64.zip" -OutFile $KubeloginZip

Write-Host "Extracting kubelogin..."
$KubeloginExtract = "$DownloadDir\kubelogin"
Expand-Archive -Path $KubeloginZip -DestinationPath $KubeloginExtract -Force

Write-Host "Locating kubelogin.exe..."
$KubeloginExe = Get-ChildItem -Path $KubeloginExtract -Recurse -Filter "kubelogin.exe" | Select-Object -First 1

if (-not $KubeloginExe) {
    throw "kubelogin.exe was not found after extraction."
}

$WindowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

Write-Host "Copying kubelogin.exe to $WindowsApps ..."
Copy-Item $KubeloginExe.FullName -Destination "$WindowsApps\kubelogin.exe" -Force

Write-Host ""
Write-Host "Installation complete."
Write-Host "Verify:"
Write-Host "  az version"
Write-Host "  kubelogin --version"

