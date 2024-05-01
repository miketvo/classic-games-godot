#
# Syntax: build.ps1 [Options] -m <build-mode>
# Options:
#   -m Specify build mode. Accepted values are 'release' and 'debug'.
#   -c (Optional) Clean build folders.
#   -h (Optional) Display help and exit.
#

[CmdletBinding()] param(
    [string]$m,
    [switch]$c,
    [switch]$h
)

if ($h.IsPresent) {
    Write-Output "Syntax: build.ps1 [Options] -m <build-mode>"
    Write-Output "Options:"
    Write-Output "  -m Specify build mode. Accepted values are 'release' and 'debug'."
    Write-Output "  -c (Optional) Clean build folders."
    Write-Output "  -h (Optional) Display this help and exit."
    exit 0
}

if ($c.IsPresent) {
    Write-Host " =====[ CLEANING BUILD DIRS ]===== " -ForegroundColor Black -BackgroundColor Magenta
    git clean -dxf -e ".godot"
    Write-Host "[ DONE ]" -ForegroundColor Magenta
}

$repositoryPath = $PSScriptRoot
switch ($m) {
    "" {
        Write-Host "Error: No build mode specified. Terminating." -ForegroundColor Yellow
        exit 0
    }
    "debug" {
        $releaseFolderPath = Join-Path -Path $repositoryPath -ChildPath "build/debug"
        $godotExportFlag = "--export-debug"
    }
    "release" {
        $releaseFolderPath = Join-Path -Path $repositoryPath -ChildPath "build/release"
        $godotExportFlag = "--export-release"
    }
    Default {
        Write-Host "Invalid build mode '$m'" -ForegroundColor Red
        exit 1
    }
}
$godotProjects = Get-ChildItem -Path $repositoryPath -Filter "project.godot" -Recurse | Select-Object -ExpandProperty Directory

Write-Host " =====[ GODOT PROJECTS REPOSITORY INFORMATION ]===== " -ForegroundColor Black -BackgroundColor Yellow
Write-Host "- Repository path: $repositoryPath" -ForegroundColor Yellow
Write-Host "- Export path: $releaseFolderPath" -ForegroundColor Yellow
Write-Host "- Detected projects:" -ForegroundColor Yellow
Write-Output $godotProjects

$buildModeText = $m.ToUpper()
Write-Host " =====[ EXPORTING PROJECTS (MODE: $buildModeText) ]===== " -ForegroundColor Black -BackgroundColor Magenta
foreach ($project in $godotProjects) {
    Write-Host "Exporting $project" -ForegroundColor Magenta
    $projectName = $project.BaseName
    $exportPresetsFile = Join-Path -Path $project -ChildPath "export_presets.cfg"
    $exportPresetsCfg = Get-Content -Path $exportPresetsFile -Raw
    $exportPresets = ($exportPresetsCfg | Select-String -Pattern '\n\nname="(.*)"' -AllMatches).Matches | ForEach-Object {
        $_.Groups[1].Value
    }
    $exportPaths = ($exportPresetsCfg | Select-String -Pattern '\nexport_path="(.*)"' -AllMatches).Matches | ForEach-Object {
        $_.Groups[1].Value
    }

    foreach ($exportPreset in $exportPresets) {
        $exportPath = $exportPaths
        if ($exportPaths -is [System.Array]) {
            $exportPath = $exportPaths[$exportPresets.IndexOf($exportPreset)]
        }
        $absoluteExportPath = Join-Path -Path $project -ChildPath $exportPath
        $exportDirectory = Split-Path -Path $absoluteExportPath -Parent
        if (-not (Test-Path -Path $exportDirectory)) {
            New-Item -ItemType Directory -Path $exportDirectory | Out-Null
        }

        Write-Output "Exporting $projectName ($exportPreset) ..."
        Set-Location -Path $project
        $godotExecutable = which godot | Out-String
        $godotExportProcess = @{
            FilePath = $godotExecutable
            ArgumentList = "--headless","--verbose",$godotExportFlag,$exportPreset
            WorkingDirectory = @project
            NoNewWindow = $true
            Wait = $true
        }
        Start-Process @godotExportProcess
        Set-Location -Path $PSScriptRoot

        $zipFileName = "$projectName-$exportPreset.zip"
        $zipFilePath = Join-Path -Path $releaseFolderPath -ChildPath $zipFileName
        if (-not (Test-Path -Path $releaseFolderPath)) {
            New-Item -ItemType Directory -Path $releaseFolderPath | Out-Null
        }
        if (Test-Path -Path $zipFilePath) {
            Remove-Item -Path $zipFilePath -Force
        }
        $archiveCommand = "zip -jr -0 $zipFilePath $exportDirectory"
        Write-Output "Archiving $projectName ($exportPreset) ..."
        Invoke-Expression -Command $archiveCommand
    }
}
Write-Host "[ DONE ]" -ForegroundColor Magenta
