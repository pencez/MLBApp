#
# theCalculations.ps1
#
function advantageCounter() {	
	$grCnt = 0
	$rdCnt = 0
	if ($homeAway -eq "Home") 
		{ $grCnt++ } else { $rdCnt++ }
	if ([int]$theVsTeamWins -gt	[int]$theVsTeamLoss)
		{ $grCnt++ } else { $rdCnt++ }
    if ($theVsPitcherEra -ge 4.50) 
		{ $grCnt++ } else { $rdCnt++ }
	if ([int]$theVsPitcherWins -gt [int]$theVsPitcherLoss) 		
		{ $grCnt++ } else { $rdCnt++ }
    if ([double]$theBatAvgHomeAway -ge .300) 
		{ $grCnt++ } else { $rdCnt++ }
    if ([double]$theBatAvgForDayofWk -ge .300) 
		{ $grCnt++ } else { $rdCnt++ }
    if ([double]$theBatAvgForDayNight -ge .300) 
		{ $grCnt++ } else { $rdCnt++ }
    if ([double]$theBatAvgVsHand -ge .300) 
		{ $grCnt++ } else { $rdCnt++ }

	return ($grCnt - $rdCnt)
}


function getRecentAvg ($timeFrame) {	
	$frameStartDate = [datetime]::parseexact($theDay, 'MM/dd/yyyy', $null)
	$frameStartDate = $frameStartDate.AddDays(-$($timeFrame)).ToString("MM/dd/yyyy")
	$theUri = "https://statsapi.mlb.com/api/v1/people/$($theBatId)/stats?stats=byDateRange&group=hitting&gameType=$($gameType)&startDate=$($frameStartDate)&endDate=$($seasonCurrDate)"
	$theFields = "stats"
	$getRecentStats = GetApiData $theUri $theFields
	
	if (!$getRecentStats) { 
		$recentAVG = .000
		$recentHits = 0
		$recentHRs = 0
		$recentABs = 0
		$recentSOs = 0
		$recentSFs = 0
		$recentBABIP = .000
	} else {
		$recentAVG = $getRecentStats.splits[0].stat.avg
		$recentHits = $getRecentStats.splits[0].stat.hits
		$recentHRs = $getRecentStats.splits[0].stat.homeRuns
		$recentABs = $getRecentStats.splits[0].stat.atBats
		$recentSOs = $getRecentStats.splits[0].stat.strikeOuts
		$recentSFs = $getRecentStats.splits[0].stat.sacFlies
		$recentBABIP = [math]::round( $(($recentHits - $recentHRs)/($recentABs - $recentHRs - $recentSOs + $recentSFs)) ,3)
	}

	return $recentAVG, $recentBABIP
}


function BuildHitProbabilityNumber() {

	#build simple counter, not weighted by average just count daily advantage
	#then build a last X days getter to determine average or span


	$baseScore = .30
	$upCnt = 0
	$downCnt = 0
	$upScore = 0
	$downScore = 0
	if ($homeAway -eq "Home") 
	{ 
		$upScore = $upScore + .2
		$upCnt = $upCnt + 1
	}
	if (($theVsTeamWins -or $theVsTeamWins -ne 0) -and ($theVsTeamLoss -or $theVsTeamLoss -ne 0)) {
		if (($theVsTeamWins/$theVsTeamLoss) -ge .500) {
			$downScore = $downScore + .1
			$downCnt = $downCnt + 1
		} else {
			$upScore = $upScore + .05
			$upCnt = $upCnt + 1
		}
	}
	
	if (!$theVsPitcherWins) { $theVsPitcherWins = 0 }
	if ($theVsPitcherWins -eq 0) {
		$upScore = $upScore + .05
		$upCnt = $upCnt + 1
	}
	if (!$theVsPitcherLoss) { $theVsPitcherLoss = 0 }
	if ($theVsPitcherLoss -eq 0) {
		$downScore = $downScore + .1
		$downCnt = $downCnt + 1
	}
	if ($theVsPitcherWins -ne 0 -and $theVsPitcherLoss -ne 0) {
		if (($theVsPitcherWins/$theVsPitcherLoss) -ge 3) {
			$downScore = $downScore + .3
			$downCnt = $downCnt + 1
		} elseif (($theVsPitcherWins/$theVsPitcherLoss) -ge 1) {
			$downScore = $downScore + .2
			$downCnt = $downCnt + 1
		} else {
			$upScore = $upScore = .1
			$upCnt = $upCnt + 1
		}
	}	

	# Score based on starting pitchers ERA
	if ($theVsPitcherEra -ge 7.00)
	{
		$upScore = $upScore + .2
		$upCnt = $upCnt + 1
	}
	elseif ($theVsPitcherEra -ge 4.00)
	{
		$upScore = $upScore + .1
		$upCnt = $upCnt + 1
	}
	elseif ($theVsPitcherEra -ge 3.00)
	{
		$downScore = $downScore + .1
		$downCnt = $downCnt + 1
	}
	else {		
		$downScore = $downScore + .2
		$downCnt = $downCnt + 1
	}	
	# Score based on batters career AVG at Home/Away
	if ([double]$theBatAvgHomeAway -ge .365)
	{
		$upScore = $upScore + ([double]$theBatAvgHomeAway * .6)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgHomeAway -ge .350)
	{
		$upScore = $upScore + ([double]$theBatAvgHomeAway * .5)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgHomeAway -ge .320)
	{
		$upScore = $upScore + ([double]$theBatAvgHomeAway * .4)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgHomeAway -le .275)
	{
		$downScore = $downScore + ([double]$theBatAvgHomeAway * .7)
		$downCnt = $downCnt + 1
	}
	elseif ([double]$theBatAvgHomeAway -le .200)
	{
		$downScore = $downScore + ([double]$theBatAvgHomeAway * .9)
		$downCnt = $downCnt + 1
	}
	else {
		$downScore = $downScore + ([double]$theBatAvgHomeAway * .1)
	}
	# Score based on batters career AVG for Day of Week	
	if ([double]$theBatAvgForDayofWk -ge .365)
	{
		$upScore = $upScore + ([double]$theBatAvgForDayofWk * .6)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgForDayofWk -ge .350)
	{
		$upScore = $upScore + ([double]$theBatAvgForDayofWk * .5)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgForDayofWk -ge .320)
	{
		$upScore = $upScore + ([double]$theBatAvgForDayofWk * .4)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgForDayofWk -le .275)
	{
		$downScore = $downScore + ([double]$theBatAvgForDayofWk * .7)
		$downCnt = $downCnt + 1
	}
	elseif ([double]$theBatAvgForDayofWk -le .200)
	{
		$downScore = $downScore + ([double]$theBatAvgForDayofWk * .9)
		$downCnt = $downCnt + 1
	}
	else {
		$downScore = $downScore + ([double]$theBatAvgForDayofWk * .1)
	}
	# Score based on batters career AVG at Day/Night
	if ([double]$theBatAvgForDayNight -ge .365)
	{
		$upScore = $upScore + ([double]$theBatAvgForDayNight * .6)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgForDayNight -ge .350)
	{
		$upScore = $upScore + ([double]$theBatAvgForDayNight * .5)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgForDayNight -ge .320)
	{
		$upScore = $upScore + ([double]$theBatAvgForDayNight * .4)
		$upCnt = $upCnt + 1
	}
	elseif ([double]$theBatAvgForDayNight -le .275)
	{
		$downScore = $downScore + ([double]$theBatAvgForDayNight * .7)
		$downCnt = $downCnt + 1
	}
	elseif ([double]$theBatAvgForDayNight -le .200)
	{
		$downScore = $downScore + ([double]$theBatAvgForDayNight * .9)
		$downCnt = $downCnt + 1
	}
	else {
		$downScore = $downScore + ([double]$theBatAvgForDayNight * .1)
	}
	# Score based on batters career AVG vs starting pitchers pitching hand
	if ($theBatAvgVsHand) {
		$zt2 = $theBatAvgVsHand.gettype()
		if ([double]$theBatAvgVsHand -ge .365)
		{
			$upScore = $upScore + ([double]$theBatAvgVsHand * .6)
			$upCnt = $upCnt + 1
		}
		elseif ([double]$theBatAvgVsHand -ge .350)
		{
			$upScore = $upScore + ([double]$theBatAvgVsHand * .5)
			$upCnt = $upCnt + 1
		}
		elseif ([double]$theBatAvgVsHand -ge .320)
		{
			$upScore = $upScore + ([double]$theBatAvgVsHand * .4)
			$upCnt = $upCnt + 1
		}
		elseif ([double]$theBatAvgVsHand -le .275)
		{
			$downScore = $downScore + ([double]$theBatAvgVsHand * .7)
			$downCnt = $downCnt + 1
		}
		elseif ([double]$theBatAvgVsHand -le .200)
		{
			$downScore = $downScore + ([double]$theBatAvgVsHand * .9)
			$downCnt = $downCnt + 1
		}
		else {
			$downScore = $downScore + ([double]$theBatAvgVsHand * .1)
		}	
	} else {
		$downScore = $downScore + .1
		$downCnt = $downCnt + 1
	}

	$gCnt = 0
	$rCnt = 0
    if ($theVsPitcherEra -ge 4.50) { $gCnt++ } else { $rCnt++ }
    if ([double]$theBatAvgHomeAway -ge .300) { $gCnt++ } else { $rCnt++ }
    if ([double]$theBatAvgForDayofWk -ge .300) { $gCnt++ } else { $rCnt++ }
    if ([double]$theBatAvgForDayNight -ge .300) { $gCnt++ } else { $rCnt++ }
    if ([double]$theBatAvgVsHand -ge .300) { $gCnt++ } else { $rCnt++ }
	
	$bonus = 0
	if ($gCnt -eq 5) { $bonus = .8 }
	elseif ($gCnt -eq 4) { $bonus = .6 }
	elseif ($gCnt -eq 3) { $bonus = .25 }
	if ($rCnt -eq 5) { $bonus = -1 }
	elseif ($rCnt -eq 4) { $bonus = -.75 }
	elseif ($rCnt -eq 3) { $bonus = -.5 }

	$bonusCnt = $upCnt - $downCnt
	$upBonus = 0
	if ($bonusCnt -ge 3) { $upBonus = .25 }
	if ($bonusCnt -ge 6) { $upBonus = .5 }

	$hitterScore = $baseScore + $upScore - $downScore + $upBonus + $bonus

	return $hitterScore
}