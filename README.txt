## KRBTGT SAFE ROTATION SCRIPT 1.0

AUTHOR: fredrik.lundstrom

CREDIT: Lauck-IT
https://github.com/Lauck-IT/KrbtgtRotation
-----------------------------------------------------------------------------------------------------------
This script provides a safe and controlled method for rotating the krbtgt password in an Active Directory environment. It includes a built-in cooldown mechanism that prevents multiple password rotations within a short time period.

The default cooldown is 7 days. It is recommended to schedule the script to run every 30 days on a each Domain Controller. New-CtmADKrbtgtKeys_Automated.ps1 must run from the Domain Controller with the PDC emulator role. Safe-run-new-krbtgt.ps1 has built in logic to detect that and exits if the Domain Controller does not have the PDC emulator role.

### INSTALLATION:
Copy the entire folder containing the scripts and "Logs" folder to a Domain Controller.
Ensure that the folder structure and file locations remain unchanged.

### USAGE:
1. Manually run "New-KrbtgtKeys.ps1" in mode 1 & 2 before any run of "New-CtmADKrbtgtKeys_Automated.ps1" to check for errors.
2. Run "Safe-run-new-krbtgt.ps1" with the test script first. ($TargetScript = "$scriptDir\Safe-run-new-krbtgt-test.ps1")
3. Make sure it works and only can be run once.
4. Delete "last_run_timestamp.txt".
5. Change $TargetScript to "$scriptDir\New-CtmADKrbtgtKeys_Automated.ps1"
6. Create a Scheduled Task on a each Domain Controller.
7. Configure the task with the following settings:

Run as: SYSTEM
Trigger: On a schedule, Monthly (recommended) or Weekly.
Action: Run a program: powershell
Add arguments: -ExecutionPolicy ByPass -File "C:\scriptdir\Safe-run-new-krbtgt.ps1"
Do not allow the task to be run on demand.
Do not allow the task to restart on fail.

The script automatically checks the cooldown timer. It will only rotate the krbtgt password when the required time interval has passed, reduce cooldown to 6 Days if you want to run it weekly.

### SAFETY NOTES:
Do not rotate the krbtgt password more frequently than recommended.
Understand the impact of krbtgt rotation before automating the process.
If possible test the procedure in a non-production environment first.
