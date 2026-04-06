# 🚀 NuGet + Octopus CI/CD with Bamboo (PowerShell)

This repository demonstrates an **end-to-end CI/CD pipeline** using **Bamboo**, **PowerShell**, **NuGet**, and **Octopus Deploy** to build, package, and deploy a .NET application.

The pipeline automates the complete software delivery lifecycle — from dependency restoration to deployment — ensuring **consistency, traceability, and reliability**.

---

## 🧭 Pipeline Overview

The pipeline executes the following stages:

- 📥 Restore dependencies from NuGet
- 🏗 Build the .NET application
- 📦 Package the application into a NuGet artifact
- 🚀 Push the artifact to Octopus Deploy for release management

---

## ⚙️ Bamboo PowerShell Script

The following PowerShell script is executed within Bamboo to orchestrate the pipeline:

```powershell
# ================================
# Bamboo CI/CD PowerShell Script
# ================================

# Variables (injected by Bamboo at runtime)
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
nuget pack "$packageName.nuspec" `
    -OutputDirectory $artifactsDir `
    -Properties "BuildNumber=$buildNumber"

# Alternative packaging using Octopus CLI
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
```

---

## 🔄 Execution Flow

The pipeline follows a structured and repeatable execution flow:

### 📥 Restore Dependencies

Fetch all required NuGet packages using the configured source:

```bash
nuget restore MySolution.sln -ConfigFile NuGet.Config
```

---

### 🏗 Build Application

Compile the .NET project in Release mode:

```bash
dotnet build MyProject.csproj -c Release
```

---

### 📦 Package Application

Generate a versioned NuGet package using Bamboo build number:

```bash
nuget pack MyProject.nuspec -OutputDirectory ./artifacts \
  -Properties BuildNumber=${bamboo.buildNumber}
```

📌 **Generated Artifact**
```
MyProject.1.0.${bamboo.buildNumber}.nupkg
```

---

### 🚀 Push Package to Octopus

Upload the package to Octopus Deploy for release orchestration:

```bash
octo push --package <package-path> \
  --server https://octopus.company.com \
  --apiKey <API_KEY> \
  --replace-existing
```

---

## 🔐 Environment Variables

Sensitive values and runtime metadata are injected via Bamboo:

| Variable              | Description                          |
|----------------------|--------------------------------------|
| `bamboo_buildNumber` | Unique build version identifier      |
| `OCTO_API_KEY`       | API key for Octopus authentication   |

---

## 📁 Output Artifacts

- 📦 NuGet package stored in `./artifacts`
- 🔢 Versioning format:  
  `MyProject.1.0.<buildNumber>.nupkg`

---

## 🏛 DevOps Best Practices Applied

- 🔐 **Secrets management** via environment variables  
- 📦 **Immutable artifacts** using build-based versioning  
- 🧩 **Separation of concerns** (build vs deployment)  
- 🔁 **Repeatable pipelines** for consistency  
- 🧾 **Traceability** through versioned artifacts  

---

## 📊 Pipeline Architecture (Conceptual)

```
Developer → Bamboo CI → PowerShell Script → NuGet Package → Octopus Deploy → Environment
```

---

## 📌 Summary

This project demonstrates a **production-style CI/CD pipeline** that automates:

- Application build and packaging  
- Artifact versioning and management  
- Deployment integration with Octopus  

It provides a strong foundation for implementing **scalable and maintainable DevOps pipelines** in enterprise environments.

---
