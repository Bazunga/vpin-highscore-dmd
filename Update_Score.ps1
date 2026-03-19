param([string]$rom, [string]$table)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "Highscore_Lib.ps1")

$Status = Generate-ScoreGif -RomName $rom -VpxName $table
Write-Host "Process completed: $Status"