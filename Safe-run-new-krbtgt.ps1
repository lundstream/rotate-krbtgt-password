# Get current directory of script and store it in variable $scriptDir
try {$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path -ErrorAction Stop}
catch
{
    try {$scriptDir = Split-Path -Parent $psISE.CurrentFile.FullPath -ErrorAction Stop}
    catch {$scriptDir = Split-Path -Path $psEditor.GetEditorContext().CurrentFile.Path -ErrorAction SilentlyContinue}

    if ($null -eq $scriptDir -or $scriptDir -notmatch [regex]::Escape("\") -or $scriptDir -like "$env:WINDIR*")
    {
        Write-Host "Break! Can't get current directory for variable scriptDir: $scriptDir"
        break            
    }
    else
    {
        Write-Host "Variable scriptDir is set to: `"$scriptDir`""
    }
}

# Start-Transcript
$psTranscriptPath = "$scriptDir\psTranscripts"
Start-Transcript -Path "$psTranscriptPath\psTranscript_$(Get-Date -Format yyyy-MM-dd_HH).log" -Append

# Path to the script you want to run, switch after test run
$TargetScript = "$scriptDir\Safe-run-new-krbtgt-test.ps1"
#$TargetScript = "$scriptDir\New-CtmADKrbtgtKeys_Automated.ps1"

# Location to store last-run timestamp
$TimestampFile = "$scriptDir\last_run_timestamp.txt"

# How many days must pass before the script can run again?
$CooldownDays = 6

# Get current PDC emulator
$PDC = (Get-ADDomain).PDCEmulator
$LocalDC = ([System.Net.Dns]::GetHostByName(($env:COMPUTERNAME))).HostName

if ($LocalDC -ne $PDC) {
    Write-Output "[$LocalDC] Not PDC Emulator – exiting."
    exit 0
}

# Check if timestamp file exists
if (Test-Path $TimestampFile) {
    $LastRun = Get-Content $TimestampFile | Get-Date

    # Calculate next allowed run time
    $NextAllowed = $LastRun.AddDays($CooldownDays)
    $Now = Get-Date

    if ($Now -lt $NextAllowed) {
        $Remaining = $NextAllowed - $Now
        Write-Host "Script cannot run yet." -ForegroundColor Red
        Write-Host ("   Try again in {0} days, {1} hours, {2} minutes." -f `
            $Remaining.Days, $Remaining.Hours, $Remaining.Minutes)
        exit
    }
}

# Run the script
Write-Host "Running script..." -ForegroundColor Green
& $TargetScript

# Update timestamp
(Get-Date).ToString("o") | Out-File $TimestampFile -Force

Write-Host "Script completed. Next allowed run: $((Get-Date).AddDays($CooldownDays).ToString("yyyy-MM-dd HH:mm"))"

Stop-Transcript