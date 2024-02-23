#
# Syntax: build.ps1 [Options] -m <build-mode>
# Options:
#   -m Specify build mode. Accepted values are 'release' and 'debug'.
#   -h (Optional) Display help and exit.
#

[CmdletBinding()] param(
    [string]$m,
    [switch]$h
)

if ($h.IsPresent) {
    Write-Output "Syntax: build.ps1 [Options] -m <build-mode>"
    Write-Output "Options:"
    Write-Output "  -m Specify build mode. Accepted values are 'release' and 'debug'."
    Write-Output "  -h (Optional) Display this help and exit."
    exit 0
}


$repositoryPath = $PSScriptRoot
switch ($m) {
    "" {
        Write-Host "Error: No build mode specified. Try 'build.sh -h' for more information." -ForegroundColor Red
        exit 1
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

Write-Output("===== [ GODOT PROJECTS REPOSITORY INFORMATION ]===== ")
Write-Output("- Repository path: $repositoryPath")
Write-Output("- Export path: $releaseFolderPath")
Write-Output("- Detected projects:")
Write-Output($godotProjects)

$buildModeText = $m.ToUpper()
Write-Output("`n`n===== [ EXPORTING PROJECTS (MODE: $buildModeText) ] =====")
foreach ($project in $godotProjects) {
    Write-Output("`n`n[ Exporting $project ]`n")
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

        Set-Location -Path $project
        $godotExportCommand = "godot --headless $godotExportFlag ""$exportPreset"""
        Write-Output($godotExportCommand)
        Invoke-Expression -Command $godotExportCommand
        Set-Location -Path $PSScriptRoot

        $zipFileSource = Join-Path -Path $exportDirectory -ChildPath "*"
        $zipFileName = "$projectName-$exportPreset.zip"
        $zipFilePath = Join-Path -Path $releaseFolderPath -ChildPath $zipFileName
        if (-not (Test-Path -Path $releaseFolderPath)) {
            New-Item -ItemType Directory -Path $releaseFolderPath | Out-Null
        }
        if (Test-Path -Path $zipFilePath) {
            Remove-Item -Path $zipFilePath -Force
        }
        Compress-Archive -Path $zipFileSource -DestinationPath $zipFilePath
        Write-Output("Packed $zipFileSource into $zipFilePath`n")
    }

    Write-Output("`n[ Project exported ]")
}
Write-Output("`n`n[ DONE ]")
