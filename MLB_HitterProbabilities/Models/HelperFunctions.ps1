#
# HelperFunctions.ps1
#

Function LogWrite
{
   Param ([string]$logstring)
   #Add-content $logFile -value $logstring
   Write-Host $logstring
}

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

function Get-UserVariable ($Name = '*')
{
  # these variables may exist in certain environments (like ISE, or after use of foreach)
  $special = 'ps','psise','psunsupportedconsoleapplications', 'foreach', 'profile'

  $ps = [PowerShell]::Create()
  $null = $ps.AddScript('$null=$host;Get-Variable') 
  $reserved = $ps.Invoke() | 
    Select-Object -ExpandProperty Name
  $ps.Runspace.Close()
  $ps.Dispose()
  Get-Variable -Scope Global | 
    Where-Object Name -like $Name |
    Where-Object Name -ne "dte" |
    Where-Object { $reserved -notcontains $_.Name } |
    Where-Object { $special -notcontains $_.Name } |
    Where-Object Name 
}
