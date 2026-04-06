# ================================
# Bamboo CI/CD PowerShell Script
# ================================

# Variables (Bamboo injects these at runtime)
$solution = "MySolution.sln"
$project = "MyProject.csproj"
$buildNumber = $env:bamboo_buildNumber
$artifactsDir = "artifacts"
$nugetConfig = "NuGet.Config"
$packageName = "MyProject"
$octopusServer = "https://octopus.company.com"
$octopusApiKey = $env:OCTO_API_KEY
$octopusRepo = "nuget-dev"

# Ensure artifacts directory exists
if (!(Test-Path $artifactsDir)) {
    New-Item -ItemType Directory -Path $artifactsDir | Out-Null
}

Write-Host "=== Restoring NuGet packages ==="
nuget restore $solution -ConfigFile $nugetConfig

Write-Host "=== Building .NET Core API ==="
dotnet build $project -c Release

Write-Host "=== Packing NuGet package ==="
# Option 1: Using nuget.exe
nuget pack "$packageName.nuspec" `
    -OutputDirectory $artifactsDir `
    -Properties "BuildNumber=$buildNumber"

# Option 2: Using Octopus CLI (octo.exe)
# octo pack --id=$packageName --version=1.0.$buildNumber `
#           --outFolder=$artifactsDir --basePath=bin\Release

Write-Host "=== Generated package ==="
Get-ChildItem $artifactsDir -Filter "*.nupkg"

Write-Host "=== Pushing package to Octopus ==="
$packagePath = Get-ChildItem $artifactsDir -Filter "*.nupkg" | Select-Object -First 1
octo push --package $packagePath.FullName `
          --server $octopusServer `
          --apiKey $octopusApiKey `
          --replace-existing
