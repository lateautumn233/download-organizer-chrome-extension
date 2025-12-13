# Requires PowerShell 5.1+
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $ScriptDir

$OutDir = 'dist'
$ArchiveName = 'download-organizer.zip'
$ArchivePath = Join-Path -Path $OutDir -ChildPath $ArchiveName

# 添加调试信息
Write-Host "ArchivePath: $ArchivePath"
Write-Host "ArchivePath Type: $($ArchivePath.GetType().FullName)"

if (-not (Test-Path -Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

if (Test-Path -Path $ArchivePath) {
    try {
        # 确保使用字符串路径
        $ArchivePathStr = [string]$ArchivePath
        Remove-Item -Path $ArchivePathStr -Force
        Write-Host "Successfully removed existing archive"
    } catch {
        Write-Host "Error removing existing archive: $($_.Exception.Message)"
        # 使用.NET API作为备用方法
        try {
            [System.IO.File]::Delete($ArchivePath)
            Write-Host "Successfully removed existing archive using .NET API"
        } catch {
            Write-Host "Failed to remove existing archive using .NET API: $($_.Exception.Message)"
        }
    }
}

$Excludes = @(
    '.git',
    'dist',
    'package-extension.sh',
    'package-extension.ps1',
    'AGENTS.md'
    '.gitignore'
)

$Entries = Get-ChildItem -Force | Where-Object { $Excludes -notcontains $_.Name }

if (-not $Entries) {
    Write-Error 'No files found to package.'
    exit 1
}

Compress-Archive -Path ($Entries | ForEach-Object { $_.FullName }) -DestinationPath $ArchivePath -Force

Write-Host "Packaged extension at $ArchivePath"
