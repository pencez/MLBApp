#
# Lucky4Life.ps1
#
function Get-UserVariable ($Name = '*') {
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

function RepeaterForNumber($Number, $Repeater) {
	$listNum = @()
	for ($i = 0; $i -lt $Repeater; $i++ ) {
		$listNum += $Number
	}
	return $listNum
}


########################################
$basePath = "C:\Users\pencez\source\repos\MLBApp\MLB_HitterProbabilities\L4L_Data"
$ball1 = 0
$ball2 = 0
$ball3 = 0
$ball4 = 0
$ball5 = 0

foreach ($ball in 1,2,3,4,5) {
	$theBallStats = Get-Content -Raw -Path "$($basePath)\Ball$($ball).json" | Out-String | ConvertFrom-Json

	$ballStart = $theBallStats.BallInfo.rangeMin
	$ballEnd = $theBallStats.BallInfo.rangeMax
	Write-Host "Ball $ball Stats:"
	Write-Host "   Start..End:"
	Write-Host "   -- $ballStart..$ballEnd"

	$ballInputRange = [System.Collections.ArrayList]@()
	$n = $ballStart
	for ($n = $ballStart; $n -lt ($ballEnd + 1); $n++) {
		$o = $theBallStats.BallInfo.range | Where-Object { $_.number -eq $n } | Select-Object -ExpandProperty odds
		$ballInputRange += RepeaterForNumber $n $o
	}	
	#$ballInputRange = $ballInputRange.TrimEnd(',')
	#$ballInputRangeStr = ($ballInputRange | Out-String) -split "`n"
	Write-Host "   Weighted Range:"	
	Write-Host "   -- $ballInputRange"

	$ballExclude = $ball1, $ball2, $ball3, $ball4
	$ballRandomRange = @()
	$ballRandomRange = $ballInputRange | Where-Object { $ballExclude -notcontains $_ }
	$selectedBall = Get-Random -InputObject $ballRandomRange
	Set-Variable -Name "ball$ball" -Value $selectedBall
	Write-Host "Ball $ball = $selectedBall" 
}

$ballList = $ball1,$ball2,$ball3,$ball4,$ball5
$Numbers = $ballList | Sort-Object


#Lucky Ball
$luckyBallInputRange = 1..18
$luckyBallExclude = 8
$luckyBallRandomRange = $luckyBallInputRange | Where-Object { $luckyBallExclude -notcontains $_ }
$luckyBall = Get-Random -InputObject $luckyBallRandomRange


Write-Host "Here are your numbers: $Numbers LB: $luckyBall"

# This will clear all variables used in script
Get-UserVariable | Clear-Variable

Exit






####################
 ##### Ball 1 #####
####################
<#
$ball1 = 0
$theBall1Stats = Get-Content -Raw -Path "$($basePath)\Ball1.json" | Out-String | ConvertFrom-Json

$ball1Start = $theBall1Stats.BallInfo.rangeMin
$ball1End = $theBall1Stats.BallInfo.rangeMax
Write-Host "Ball 1 Stats:"
Write-Host "   Start..End:"
Write-Host "   -- $ball1Start..$ball1End"

$b1InputRange = @()
$n = $ball1Start
for ($n = $ball1Start; $n -lt $ball1End; $n++) {
	$o = $theBall1Stats.BallInfo.range | where { $_.number -eq $n } | Select -ExpandProperty odds
	$b1InputRange = RepeaterForNumber $n $o $b1InputRange
}	
$b1InputRange = $b1InputRange.TrimEnd(',')
Write-Host "   Weighted Range:"	
Write-Host "   -- $b1InputRange"

$b1Exclude = 0
$ball1RandomRange = $b1InputRange | Where-Object { $b1Exclude -notcontains $_ }
$ball1 =  Get-Random -InputObject $ball1RandomRange
Write-Host "Ball 1: $ball1"
#>

<#
$ballInputRange = 1..26


Write-Host "for Ball 1: $listNum"


#Ball 2
$b2InputRange = 4..18
$b2Exclude = $ball1
$ball2RandomRange = $b2InputRange | Where-Object { $b2Exclude -notcontains $_ }
$ball2 = Get-Random -InputObject $ball2RandomRange

#Ball 3
$b3InputRange = 21..31
$b3Exclude = $ball1,$ball2
$ball3RandomRange = $b3InputRange | Where-Object { $b3Exclude -notcontains $_ }
$ball3 = Get-Random -InputObject $ball3RandomRange

#Ball 4
$b4InputRange = 28..44
$b4Exclude = $ball1,$ball2,$ball3
$ball4RandomRange = $b4InputRange | Where-Object { $b4Exclude -notcontains $_ }
$ball4 = Get-Random -InputObject $ball4RandomRange

#Ball 5
$b5InputRange = 37..48
$b5Exclude = $ball1,$ball2,$ball3,$ball4
$ball5RandomRange = $b5InputRange | Where-Object { $b5Exclude -notcontains $_ }
$ball5 = Get-Random -InputObject $ball5RandomRange


#Lucky Ball
$luckyBallInputRange = 1..18
$luckyBallExclude = 12
$luckyBallRandomRange = $luckyBallInputRange | Where-Object { $luckyBallExclude -notcontains $_ }
$luckyBall = Get-Random -InputObject $luckyBallRandomRange

Write-Host "Winning Numbers: $ball1 $ball2 $ball3 $ball4 $ball5 LB: $luckyBall"

Exit
#>