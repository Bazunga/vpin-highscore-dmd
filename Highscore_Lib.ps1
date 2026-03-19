# --- LOAD CONFIGURATION ---
$ConfigPath = Join-Path $PSScriptRoot "config.psd1"
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Configuration file 'config.psd1' not found!"; exit
}

$global:Cfg = Import-PowerShellDataFile -Path $ConfigPath
$global:DebugEnabled = [System.Convert]::ToBoolean($Cfg.Settings.DebugEnabled)
$LogFile = Join-Path $PSScriptRoot "highscore_debug.log"

# --- LOGGING SYSTEM ---
function Write-Log {
    param([string]$Message, [string]$Level = "INFO", [switch]$Screen)
    
    $Stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FullMessage = "[$Stamp] [$Level] $Message"
    
    if ($global:DebugEnabled) { $FullMessage | Out-File $LogFile -Append }

    if ($Screen) {
        $Color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN"  { "Yellow" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
        Write-Host $FullMessage -ForegroundColor $Color
    }
}

function Generate-ScoreGif {
    param([string]$RomName, [string]$VpxName)
    
    Write-Log "--- Starting Process for $VpxName ($RomName) ---"
    
    # 1. Validation
    if (-not (Test-Path $Cfg.Paths.PinemhiExec)) { 
        Write-Log "Pinemhi not found at $($Cfg.Paths.PinemhiExec)" "ERROR"
        return "Error: Pinemhi missing" 
    }
    
    # Define the output path directly from the PowerShell data file
    $OutputPath = $Cfg.Paths.MediaRootDir
    $OutputFile = Join-Path $OutputPath "$VpxName.gif"
    
    # 2. Extract scores
    # Store the script directory so we can return to it after Pinemhi
    $ScriptDir = $PSScriptRoot
    $PinemhiDir = Split-Path -Parent $Cfg.Paths.PinemhiExec

    Set-Location $PinemhiDir
    $RawOutput = & $Cfg.Paths.PinemhiExec $RomName | Out-String
    $ScoreMatches = $RawOutput -split "`n" | Select-String -Pattern "^\s*[1-3]\)"
    
    if (-not $ScoreMatches) { 
        Write-Log "No scores found for $RomName" "WARN"
        Set-Location $ScriptDir
        return "No scores" 
    }

    # Filter valid lines
    $ScoreData = foreach ($Line in $ScoreMatches) {
		Write-Log "Raw line value : $Line"

		$Parts = $Line.ToString().Split(')', [System.StringSplitOptions]::RemoveEmptyEntries)

		if ($Parts.Count -lt 2) {
			Write-Log "Invalid line format: missing ')'"
			continue
		}

		$nameAndScore = $Parts[1].Trim()
		
		Write-Log "Raw Name and Score : $nameAndScore"

		if ([string]::IsNullOrWhiteSpace($nameAndScore) -or $nameAndScore.Length -lt 3) {
			Write-Log "Invalid name/score format: too short"
			continue
		}

		$name = $nameAndScore.Substring(0, 3).Trim()
		$score = $nameAndScore.Substring(3).Trim()

		Write-Log "Name : $name"
		Write-Log "Score : $score"

		if (-not [string]::IsNullOrWhiteSpace($name) -and -not [string]::IsNullOrWhiteSpace($score)) {
			[PSCustomObject]@{
				Name  = $name
				Score = ($score -replace '[^0-9]', '.')
			}
		}
		else {
			Write-Log "At least one value is empty"
		}
	}
	
	
    # Return to the script directory for Magick and the icons
    Set-Location $ScriptDir

    # 3. Cleanup (Only overwrite the existing GIF)
    if (Test-Path $OutputFile) {
        Write-Log "Deleting existing GIF to overwrite"
        Remove-Item $OutputFile -Force
    }

    # 4. Generate frames (Icons only on names)
    $IconFolder = Join-Path $PSScriptRoot "image"
    $Icons = @(
        (Join-Path $IconFolder "or.png"),
        (Join-Path $IconFolder "silver.png"),
        (Join-Path $IconFolder "bronze.png")
    )

    $Colors = @($Cfg.Colors.Rank1, $Cfg.Colors.Rank1, $Cfg.Colors.Rank2, $Cfg.Colors.Rank2, $Cfg.Colors.Rank3, $Cfg.Colors.Rank3)
	Write-Log "Generates image for : $($ScoreData[2].Name) $($ScoreData[2].Score)"
    $Texts  = @($ScoreData[0].Name, $ScoreData[0].Score, $ScoreData[1].Name, $ScoreData[1].Score, $ScoreData[2].Name, $ScoreData[2].Score)
    
    for ($i = 0; $i -lt 6; $i++) {
        $RankIndex = [math]::Floor($i / 2)
        $Icon = $Icons[$RankIndex]
        $Size = if (($i+1) % 2 -ne 0) { 18 } else { 14 }
        
        # Determine whether this is a NAME frame (even index: 0, 2, 4) or a SCORE frame (odd index: 1, 3, 5)
        $isNameFrame = ($i % 2 -eq 0)

        if ($isNameFrame -and (Test-Path $Icon)) {
            Write-Log "Generating Name Frame $($i+1) with dual icons: $Icon"
            
            # --- DOUBLE ICON (LEFT AND RIGHT) ---
            # Place the same icon on the west (left) and east (right) sides
            # Keep the text centered with no offset (0,0) because the icons balance each other
            & $Cfg.Paths.MagickExec -size 128x32 xc:black `
                "$Icon" -gravity west -composite `
                "$Icon" -gravity east -composite `
                -fill $Colors[$i] -font $Cfg.Settings.FontFace -pointsize $Size -gravity center `
                -draw "text 0,0 '$($Texts[$i])'" "frame$($i+1).png"
        } else {
            # --- SCORE FRAME (OR MISSING ICON) ---
            Write-Log "Generating Score Frame $($i+1) (Text only)"
            & $Cfg.Paths.MagickExec -size 128x32 xc:black `
                -fill $Colors[$i] -font $Cfg.Settings.FontFace -pointsize $Size -gravity center `
                -draw "text 0,0 '$($Texts[$i])'" "frame$($i+1).png"
        }
    }

    # 5. Final assembly
    $Repeat = [int]$Cfg.Settings.FrameRepeat
    $Frames = @(); for($i=1;$i -le 6;$i++){ for($j=0;$j -lt $Repeat;$j++){ $Frames += "frame$i.png" } }
    
    & $Cfg.Paths.MagickExec -delay 2 $Frames -loop 0 "$OutputFile"
    
    # Clean up temporary files
    Remove-Item frame*.png -ErrorAction SilentlyContinue

    if (Test-Path $OutputFile) {
        Write-Log "Successfully generated: $OutputFile" "SUCCESS"
        return "OK"
    } else {
        Write-Log "Magick assembly failed" "ERROR"
        return "Magick Error"
    }
}