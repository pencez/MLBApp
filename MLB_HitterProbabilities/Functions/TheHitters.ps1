#
# TheHitters.ps1
#


function buildHitterDetailsObjectTesting($getTopHitters, $testing) {
	$theHittersDetails = Get-Content -Raw -Path "$($basePath)\Data\Test\hittingLeaders_Details.json" | Out-String | ConvertFrom-Json
	$theBatterList = @()
	foreach($theBatters in $theHittersDetails.TopHitterDetails.BatterID ) { 
		$theBatterList += $theBatters
	}

	$theTopHittersDetails = @()
	#use "leaders" instead of "splits" in prod
	for ($z=0; $z -lt $getTopHitters.splits.length; $z++) {
		$batterID = $getTopHitters.splits[$z].player.id
		# Do we need details for hitter?			
		if ($theBatterList -match $batterID) {
			# We have batter details already			
			$getDetailsYN = "No"
		} else {			
			$getDetailsYN = "Yes"	
		} 

		if ($getDetailsYN -eq "Yes") {
			# Get the details for the batter
			$batterName = $getTopHitters.splits[$z].player.fullname			
			$batterDebut = $getTopHitters.splits[$z].player.mlbDebutDate
			$batterTeamID = $getTopHitters.splits[$z].team.id
			$batterTeamName = $getTopHitters.splits[$z].team.name	
			
			$batterSide = $getTopHitters.splits[$z].player.batSide.code
			$batterRank = $getTopHitters.splits[$z].rank
			$batterAverage = $getTopHitters.splits[$z].stat.avg			
			$batterHits = $getTopHitters.splits[$z].stat.hits
			$batterHRs = $getTopHitters.splits[$z].stat.homeRuns
			$batterABs = $getTopHitters.splits[$z].stat.atBats
			$batterKs = $getTopHitters.splits[$z].stat.strikeOuts
			$batterSFs = $getTopHitters.splits[$z].stat.sacFlies
			if ( ($batterHits - $batterHRs) -eq 0 -or ($batterABs - $batterHRs - $batterKs + $batterSFs) -eq 0) {
				$batterBABIP = ".000"
			} else {
				$batterBABIP = [math]::round( $(($batterHits - $batterHRs)/($batterABs - $batterHRs - $batterKs + $batterSFs)) ,3).toString(".###")
				if ($batterBABIP -eq "1") { $batterBABIP = "1.000" }
			}

			$batterCareerAvg = $getTopHitters.splits[$z].player.stats[0].splits[0].stat.avg
			$batterCareerBabip = $getTopHitters.splits[$z].player.stats[0].splits[0].stat.babip
			
			write-host "********** Stats for $($batterName) **********"
			
			
			$sitCodes = @("a","h","d","n","g","t","vl","vr","preas","posas","4","5","6","7","8","9","dmo","dtu","dwe","dth","dfr","dsa","dsu","twn","tls","taw","tal")
			$sitDescs = @("Away","Home","Day","Night","Grass","Turf","VsLefty","VsRighty","PreAllStar","PostAllStar","Apr","May","Jun","Jul","Aug","Sep","Mon","Tue","Wed","Thu","Fri","Sat","Sun","TeamWins","TeamLoss","TeamAfterW","TeamAfterL")
			#$sitCodes = @("a","h")
			#$sitDescs = @("Away","Home")
			
			foreach ($sitDesc in $sitDescs) {
				Set-Variable -Name "batterTotalHits$sitDesc" -Value 0
				Set-Variable -Name "batterTotalAtBats$sitDesc" -Value 0
				Set-Variable -Name "batterTotalHomeRuns$sitDesc" -Value 0
				Set-Variable -Name "batterTotalStrikeOuts$sitDesc" -Value 0
				Set-Variable -Name "batterTotalSacFlies$sitDesc" -Value 0
			}


			$theSeason = [int]$batterDebut.substring(0,4)
			do {
				#$theSeason = [int]$theSeason
				#write-host "Season is $($theSeason):"
				$theUri = "https://statsapi.mlb.com/api/v1/people/$($batterID)?hydrate=stats(type=statSplits,sitCodes=[a,h,d,n,g,t,vl,vr,dsa,dsu,preas,posas,4,5,6,7,8,9,dmo,dtu,dwe,dth,dfr,twn,tls,taw,tal],sportId=1,gameType=$($gameType),season=$($theSeason))"
				#$theUri = "https://statsapi.mlb.com/api/v1/people/$($batterID)?hydrate=stats(type=statSplits,sitCodes=[a,h],sportId=1,gameType=$($gameType),season=$($theSeason))"
				$theFields = "people"
				$getHittersStats = GetApiData $theUri $theFields


				$hitsDesc = "$($sitDesc)Hits"
				$atBatsDesc = "$($sitDesc)AtBats"
				$homeRunsDesc = "$($sitDesc)HRs"
				$strikOutsDesc = "$($sitDesc)Ks"
				$sacFliesDesc = "$($sitDesc)SFs"
				foreach ($sitCode in $sitCodes) {
					$codeIndex = $sitCodes.IndexOf($sitCode)
					$sitDesc = $sitDescs[$sitCodes.IndexOf($sitCode)]
					$c = 0
					do {
						$tmpHits = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($hitsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.hits}} | Select -ExpandProperty $($hitsDesc)
						if ($tmpHits) {
							$tmpAtBats = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($atBatsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.atBats}} | Select -ExpandProperty $($atBatsDesc)
							$tmpHomeRuns = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($homeRunsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.homeRuns}} | Select -ExpandProperty $($homeRunsDesc)
							$tmpStrikeOuts = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($strikOutsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.strikeOuts}} | Select -ExpandProperty $($strikOutsDesc)
							$tmpSacFlies = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($sacFliesDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.sacFlies}} | Select -ExpandProperty $($sacFliesDesc)
							Set-Variable -Name "batterHits$sitDesc" -Value $tmpHits
							Set-Variable -Name "batterAtBats$sitDesc" -Value $tmpAtBats
							Set-Variable -Name "batterHomeRuns$sitDesc" -Value $tmpHomeRuns
							Set-Variable -Name "batterStrikeOuts$sitDesc" -Value $tmpStrikeOuts
							Set-Variable -Name "batterSacFlies$sitDesc" -Value $tmpSacFlies
							
			<#
			write-host "batterHits$sitDesc $(Get-Variable -Name "batterHits$sitDesc" -ValueOnly)"
			write-host "batterAtBats$sitDesc $(Get-Variable -Name "batterAtBats$sitDesc" -ValueOnly)"
			write-host "batterHomeRuns$sitDesc $(Get-Variable -Name "batterHomeRuns$sitDesc" -ValueOnly)"
			write-host "batterStrikeOuts$sitDesc $(Get-Variable -Name "batterStrikeOuts$sitDesc" -ValueOnly)"
			write-host "batterSacFlies$sitDesc $(Get-Variable -Name "batterSacFlies$sitDesc" -ValueOnly)"
			#>	
							$tmpTotalHits = ([int](Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterHits$sitDesc" -ValueOnly))
							$tmpTotalAtBats = ([int](Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterAtBats$sitDesc" -ValueOnly))
							$tmpTotalHomeRuns = ([int](Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterHomeRuns$sitDesc" -ValueOnly))
							$tmpTotalStrikeOuts = ([int](Get-Variable -Name "batterTotalStrikeOuts$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterStrikeOuts$sitDesc" -ValueOnly))
							$tmpTotalSacFlies = ([int](Get-Variable -Name "batterTotalSacFlies$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterSacFlies$sitDesc" -ValueOnly))

							Set-Variable -Name "batterTotalHits$sitDesc" -Value $tmpTotalHits
							Set-Variable -Name "batterTotalAtBats$sitDesc" -Value $tmpTotalAtBats
							Set-Variable -Name "batterTotalHomeRuns$sitDesc" -Value $tmpTotalHomeRuns
							Set-Variable -Name "batterTotalStrikeOuts$sitDesc" -Value $tmpTotalStrikeOuts
							Set-Variable -Name "batterTotalSacFlies$sitDesc" -Value $tmpTotalSacFlies
			#<#
			if ($theSeason -eq "2017") {
				write-host "batterTotalHits$sitDesc $(Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly)"
				write-host "batterTotalAtBats$sitDesc $(Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly)"
				write-host "batterTotalHomeRuns$sitDesc $(Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly)"
				write-host "batterTotalStrikeOuts$sitDesc $(Get-Variable -Name "batterTotalStrikeOuts$sitDesc" -ValueOnly)"
				write-host "batterTotalSacFlies$sitDesc $(Get-Variable -Name "batterTotalSacFlies$sitDesc" -ValueOnly)"
			}
			#>
						}
						if ($tmpTotalAtBats) { 
							$tmpTotalAtBats = $null
							break 
						}
						$c++
					} while ($c -lt 35)
				}
			
				$theSeason++
			# ********** change this to LT so you don't include current season **********
			} while ($theSeason -lt [int]$season)
			
			
			write-host "Batter Career & Situational AVG/BABIP:"
			write-host "batterCareerAvg $batterCareerAvg"
			write-host "batterCareerBabip $batterCareerBabip"
			foreach ($sitDesc in $sitDescs) {
				$tmpVarName = (Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly)
				if ([int]($tmpVarName) -ne 0) {
					$tempBatterAvg = [math]::round( [int](Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly) / [int](Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly) ,3).toString(".000")
					$tempBatterBabip = [math]::round( $(([int](Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly) - [int](Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly))/([int](Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly) - [int](Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly) - [int](Get-Variable -Name "batterTotalStrikeOuts$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterTotalSacFlies$sitDesc" -ValueOnly))) ,3).toString(".000")
				} else {
					$tempBatterAvg = ".000"
					$tempBatterBabip = ".000"				
				}
				Set-Variable -Name "batterAvg$sitDesc" -Value $tempBatterAvg			
				Set-Variable -Name "batterBabip$sitDesc" -Value $tempBatterBabip
			
				#<#		
				write-host "batterAvg$sitDesc $(Get-Variable -Name "batterAvg$sitDesc" -ValueOnly)"
				write-host "batterBabip$sitDesc $(Get-Variable -Name "batterBabip$sitDesc" -ValueOnly)"
				#>
			}

			# Build the json record with player details
			$theTopHittersDetails += buildTopHitterObject $getDetailsYN
		}
	}
	
	return $theTopHittersDetails
}

function buildHitterDetailsObject($getTopHitters, $testing) {
	$theHittersDetails = Get-Content -Raw -Path "$($basePath)\Data\hittingLeaders_Details.json" | Out-String | ConvertFrom-Json
	$theBatterList = @()
	foreach($theBatters in $theHittersDetails.TopHitterDetails.BatterID ) { 
		$theBatterList += $theBatters
	}

	$theTopHittersDetails = @()
	for ($z=0; $z -lt $getTopHitters.leaders.length; $z++) {
		$batterID = $getTopHitters.leaders[$z].person.id
		# Do we need details for hitter?			
		<#if ($theBatterList -match $batterID) {
			# We have batter details already			
			$getDetailsYN = "No"
		} else {			
			$getDetailsYN = "Yes"	
		}#> 
		# always get details in prod in order to refresh them!
		$getDetailsYN = "Yes"

		if ($getDetailsYN -eq "Yes") {
			# Get the details for the batter
			$batterName = $getTopHitters.leaders[$z].person.fullname			
			$batterDebut = $getTopHitters.leaders[$z].person.mlbDebutDate
			$batterTeamID = $getTopHitters.leaders[$z].team.id
			#$batterTeamName = $getTopHitters.splits[$z].team.name

			$statCnt = 0
			if ($getTopHitters.leaders[$z].person.stats[$statCnt].type.displayName -ne "Career") {
				DO {
					$statCnt++
					if ($statCnt -gt 3) { break }
				} Until ($getTopHitters.leaders[$z].person.stats[$statCnt].type.displayName -eq "Career")
			}
			$batterCareerAvg = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.avg
			$batterCareerBabip = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.babip
			
			write-host "********** Stats for $($batterName) **********"
			
				
			$sitCodes = @("a","h","d","n","g","t","vl","vr","preas","posas","4","5","6","7","8","9","dmo","dtu","dwe","dth","dfr","dsa","dsu","twn","tls","taw","tal")
			$sitDescs = @("Away","Home","Day","Night","Grass","Turf","VsLefty","VsRighty","PreAllStar","PostAllStar","Apr","May","Jun","Jul","Aug","Sep","Mon","Tue","Wed","Thu","Fri","Sat","Sun","TeamWins","TeamLoss","TeamAfterW","TeamAfterL")
			#$sitCodes = @("a","h")
			#$sitDescs = @("Away","Home")
			
			foreach ($sitDesc in $sitDescs) {
				Set-Variable -Name "batterTotalHits$sitDesc" -Value 0
				Set-Variable -Name "batterTotalAtBats$sitDesc" -Value 0
				Set-Variable -Name "batterTotalHomeRuns$sitDesc" -Value 0
				Set-Variable -Name "batterTotalStrikeOuts$sitDesc" -Value 0
				Set-Variable -Name "batterTotalSacFlies$sitDesc" -Value 0
			}


			$theSeason = [int]$batterDebut.substring(0,4)
			do {
				#$theSeason = [int]$theSeason
				#write-host "Season is $($theSeason):"
				$theUri = "https://statsapi.mlb.com/api/v1/people/$($batterID)?hydrate=stats(type=statSplits,sitCodes=[a,h,d,n,g,t,vl,vr,dsa,dsu,preas,posas,4,5,6,7,8,9,dmo,dtu,dwe,dth,dfr,twn,tls,taw,tal,d1,d7,d30],sportId=1,gameType=$($gameType),season=$($theSeason))"
				#$theUri = "https://statsapi.mlb.com/api/v1/people/$($batterID)?hydrate=stats(type=statSplits,sitCodes=[a,h],sportId=1,gameType=$($gameType),season=$($theSeason))"
				$theFields = "people"
				$getHittersStats = GetApiData $theUri $theFields


				$hitsDesc = "$($sitDesc)Hits"
				$atBatsDesc = "$($sitDesc)AtBats"
				$homeRunsDesc = "$($sitDesc)HRs"
				$strikOutsDesc = "$($sitDesc)Ks"
				$sacFliesDesc = "$($sitDesc)SFs"
				foreach ($sitCode in $sitCodes) {
					$codeIndex = $sitCodes.IndexOf($sitCode)
					$sitDesc = $sitDescs[$sitCodes.IndexOf($sitCode)]
					$c = 0
					do {
						$tmpHits = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($hitsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.hits}} | Select -ExpandProperty $($hitsDesc)
						if ($tmpHits) {
							$tmpAtBats = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($atBatsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.atBats}} | Select -ExpandProperty $($atBatsDesc)
							$tmpHomeRuns = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($homeRunsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.homeRuns}} | Select -ExpandProperty $($homeRunsDesc)
							$tmpStrikeOuts = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($strikOutsDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.strikeOuts}} | Select -ExpandProperty $($strikOutsDesc)
							$tmpSacFlies = $getHittersStats.stats[0].splits[$c] | where { $_.split.code -eq "$sitCode" } | Select-Object -Property @{ Name="$($sacFliesDesc)"; Expression={$getHittersStats.stats[0].splits[$c].stat.sacFlies}} | Select -ExpandProperty $($sacFliesDesc)
							Set-Variable -Name "batterHits$sitDesc" -Value $tmpHits
							Set-Variable -Name "batterAtBats$sitDesc" -Value $tmpAtBats
							Set-Variable -Name "batterHomeRuns$sitDesc" -Value $tmpHomeRuns
							Set-Variable -Name "batterStrikeOuts$sitDesc" -Value $tmpStrikeOuts
							Set-Variable -Name "batterSacFlies$sitDesc" -Value $tmpSacFlies
							
			<#
			write-host "batterHits$sitDesc $(Get-Variable -Name "batterHits$sitDesc" -ValueOnly)"
			write-host "batterAtBats$sitDesc $(Get-Variable -Name "batterAtBats$sitDesc" -ValueOnly)"
			write-host "batterHomeRuns$sitDesc $(Get-Variable -Name "batterHomeRuns$sitDesc" -ValueOnly)"
			write-host "batterStrikeOuts$sitDesc $(Get-Variable -Name "batterStrikeOuts$sitDesc" -ValueOnly)"
			write-host "batterSacFlies$sitDesc $(Get-Variable -Name "batterSacFlies$sitDesc" -ValueOnly)"
			#>	
							$tmpTotalHits = ([int](Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterHits$sitDesc" -ValueOnly))
							$tmpTotalAtBats = ([int](Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterAtBats$sitDesc" -ValueOnly))
							$tmpTotalHomeRuns = ([int](Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterHomeRuns$sitDesc" -ValueOnly))
							$tmpTotalStrikeOuts = ([int](Get-Variable -Name "batterTotalStrikeOuts$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterStrikeOuts$sitDesc" -ValueOnly))
							$tmpTotalSacFlies = ([int](Get-Variable -Name "batterTotalSacFlies$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterSacFlies$sitDesc" -ValueOnly))

							Set-Variable -Name "batterTotalHits$sitDesc" -Value $tmpTotalHits
							Set-Variable -Name "batterTotalAtBats$sitDesc" -Value $tmpTotalAtBats
							Set-Variable -Name "batterTotalHomeRuns$sitDesc" -Value $tmpTotalHomeRuns
							Set-Variable -Name "batterTotalStrikeOuts$sitDesc" -Value $tmpTotalStrikeOuts
							Set-Variable -Name "batterTotalSacFlies$sitDesc" -Value $tmpTotalSacFlies
			#<#
			if ($theSeason -eq "2017") {
				write-host "batterTotalHits$sitDesc $(Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly)"
				write-host "batterTotalAtBats$sitDesc $(Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly)"
				write-host "batterTotalHomeRuns$sitDesc $(Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly)"
				write-host "batterTotalStrikeOuts$sitDesc $(Get-Variable -Name "batterTotalStrikeOuts$sitDesc" -ValueOnly)"
				write-host "batterTotalSacFlies$sitDesc $(Get-Variable -Name "batterTotalSacFlies$sitDesc" -ValueOnly)"
			}
			#>
						}
						if ($tmpTotalAtBats) { 
							$tmpTotalAtBats = $null
							break 
						}
						$c++
					} while ($c -lt 35)
				}
			
				$theSeason++
			# ********** change this to LT so you don't include current season **********
			} while ($theSeason -le [int]$season)
			
			
			write-host "Batter Career & Situational AVG/BABIP:"
			write-host "batterCareerAvg $batterCareerAvg"
			write-host "batterCareerBabip $batterCareerBabip"
			foreach ($sitDesc in $sitDescs) {
				$tmpVarName = (Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly)
				if ([int]($tmpVarName) -ne 0) {
					$tempBatterAvg = [math]::round( [int](Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly) / [int](Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly) ,3).toString(".000")
					$tempBatterBabip = [math]::round( $(([int](Get-Variable -Name "batterTotalHits$sitDesc" -ValueOnly) - [int](Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly))/([int](Get-Variable -Name "batterTotalAtBats$sitDesc" -ValueOnly) - [int](Get-Variable -Name "batterTotalHomeRuns$sitDesc" -ValueOnly) - [int](Get-Variable -Name "batterTotalStrikeOuts$sitDesc" -ValueOnly) + [int](Get-Variable -Name "batterTotalSacFlies$sitDesc" -ValueOnly))) ,3).toString(".000")
				} else {
					$tempBatterAvg = ".000"
					$tempBatterBabip = ".000"				
				}
				Set-Variable -Name "batterAvg$sitDesc" -Value $tempBatterAvg			
				Set-Variable -Name "batterBabip$sitDesc" -Value $tempBatterBabip
			
				#<#		
				write-host "batterAvg$sitDesc $(Get-Variable -Name "batterAvg$sitDesc" -ValueOnly)"
				write-host "batterBabip$sitDesc $(Get-Variable -Name "batterBabip$sitDesc" -ValueOnly)"
				#>
			}

			# Build the json record with player details
			$theTopHittersDetails += buildTopHitterObject $getDetailsYN
		}
	}
	
	return $theTopHittersDetails
}


function buildHitterObject($getTopHitters, $testing) {
		
	
	$theTopHitters = @()
	if ($testing -ne "Testing") {
		for ($z=0; $z -lt $getTopHitters.leaders.length; $z++){			
			$batterID = $getTopHitters.leaders[$z].person.id
			$batterName = $getTopHitters.leaders[$z].person.fullname
			$batterTeamID = $getTopHitters.leaders[$z].team.id
			$batterTeamName = $getTopHitters.leaders[$z].team.name
			$batterSide = $getTopHitters.leaders[$z].person.batSide.code
			$batterRank = $getTopHitters.leaders[$z].rank
			#$batterAverage = $getTopHitters.leaders[$z].person.stats[1].splits[0].stat.avg	
			$batterAverage = $getTopHitters.leaders[$z].value			
			
			$statCnt = 0
			if ($getTopHitters.leaders[$z].person.stats[$statCnt].type.displayName -ne "statSplits") {
				DO {
					$statCnt++
					if ($statCnt -gt 3) { break }
				} Until ($getTopHitters.leaders[$z].person.stats[$statCnt].group.displayName -eq "hitting")
			}

			$batterHits = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.hits
			$batterHRs = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.homeRuns
			$batterABs = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.atBats
			$batterKs = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.strikeOuts
			$batterSFs = $getTopHitters.leaders[$z].person.stats[$statCnt].splits[0].stat.sacFlies
			if ( ($batterHits - $batterHRs) -eq 0 -or ($batterABs - $batterHRs - $batterKs + $batterSFs) -eq 0) {
				$batterBABIP = ".000"
			} else {
				$batterBABIP = [math]::round( $(($batterHits - $batterHRs)/($batterABs - $batterHRs - $batterKs + $batterSFs)) ,3).toString(".###")				
			}
					
			$theTopHitters += buildTopHitterObject "No"
		}
	} else {
		# this is my testing area
		for ($z=0; $z -lt $getTopHitters.splits.length; $z++){
			$batterID = $getTopHitters.splits[$z].player.id
			$batterName = $getTopHitters.splits[$z].player.fullname
			$batterTeamID = $getTopHitters.splits[$z].team.id
			$batterTeamName = $getTopHitters.splits[$z].team.name
			$batterSide = $getTopHitters.splits[$z].player.batSide.code
			$batterRank = $getTopHitters.splits[$z].rank
			$batterAverage = $getTopHitters.splits[$z].stat.avg			
			$batterHits = $getTopHitters.splits[$z].stat.hits
			$batterHRs = $getTopHitters.splits[$z].stat.homeRuns
			$batterABs = $getTopHitters.splits[$z].stat.atBats
			$batterKs = $getTopHitters.splits[$z].stat.strikeOuts
			$batterSFs = $getTopHitters.splits[$z].stat.sacFlies
			$batterBABIP = [math]::round( $(($batterHits - $batterHRs)/($batterABs - $batterHRs - $batterKs + $batterSFs)) ,3).toString(".###")
			
			$theTopHitters += buildTopHitterObject "No"
		}
	}	
	
	return $theTopHitters
}

function buildTopHitterObject($getDetailsYN) {
	#build the return object with names
	$obj = New-Object -TypeName psobject
	$obj | Add-Member -MemberType NoteProperty -Name BatterID -Value $batterID
	$obj | Add-Member -MemberType NoteProperty -Name BatterName -Value $batterName
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeamID -Value $batterTeamID
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeamName -Value $batterTeamName
	$obj | Add-Member -MemberType NoteProperty -Name BatterHittingSide -Value $batterSide
	$obj | Add-Member -MemberType NoteProperty -Name BatterRank -Value $batterRank
	$obj | Add-Member -MemberType NoteProperty -Name BatterCurrentAverage -Value $batterAverage
	$obj | Add-Member -MemberType NoteProperty -Name BatterCurrentBABIP -Value $batterBABIP
	if ($getDetailsYN -eq "Yes") {		 
		$obj | Add-Member -MemberType NoteProperty -Name BatterCareerAvg -Value $batterCareerAvg 
		$obj | Add-Member -MemberType NoteProperty -Name BatterCareerBabip -Value $batterCareerBabip
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgHome -Value $batterAvgHome
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipHome -Value $batterBabipHome
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgAway -Value $batterAvgAway
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipAway -Value $batterBabipAway
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgDay -Value $batterAvgDay
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipDay -Value $batterBabipDay
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgNight -Value $batterAvgNight
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipNight -Value $batterBabipNight
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgGrass -Value $batterAvgGrass
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipGrass -Value $batterBabipGrass
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgTurf -Value $batterAvgTurf
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipTurf -Value $batterBabipTurf
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgToLefty -Value $batterAvgVsLefty
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipToLefty -Value $batterBabipVsLefty
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgToRighty -Value $batterAvgVsRighty
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipToRighty -Value $batterBabipVsRighty		
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgTeamWins -Value $batterAvgTeamWins
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipTeamWins -Value $batterBabipTeamWins
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgTeamLoss -Value $batterAvgTeamLoss
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipTeamLoss -Value $batterBabipTeamLoss
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgTeamAfterW -Value $batterAvgTeamAfterW
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipTeamAfterW -Value $batterBabipTeamAfterW
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgTeamAfterL -Value $batterAvgTeamAfterL
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipTeamAfterL -Value $batterBabipTeamAfterL
		# Stats based on timeframe
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgPreAllStar -Value $batterAvgPreAllStar
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipPreAllStar -Value $batterBabipPreAllStar
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgPostAllStar -Value $batterAvgPostAllStar
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipPostAllStar -Value $batterBabipPostAllStar
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgApr -Value $batterAvgApr
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipApr -Value $batterBabipApr
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgMay -Value $batterAvgMay
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipMay -Value $batterBabipMay
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgJun -Value $batterAvgJun
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipJun -Value $batterBabipJun
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgJul -Value $batterAvgJul
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipJul -Value $batterBabipJul
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgAug -Value $batterAvgAug
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipAug -Value $batterBabipAug
		$obj | Add-Member -MemberType NoteProperty -Name batterAvgSep -Value $batterAvgSep
		$obj | Add-Member -MemberType NoteProperty -Name batterBabipSep -Value $batterBabipSep
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgMondays -Value $batterAvgMon
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipMondays -Value $batterBabipMon
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgTuesdays -Value $batterAvgTue
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipTuesdays -Value $batterBabipTue
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgWednesdays -Value $batterAvgWed
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipWednesdays -Value $batterBabipWed
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgThursdays -Value $batterAvgThu
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipThursdays -Value $batterBabipThu
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgFridays -Value $batterAvgFri
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipFridays -Value $batterBabipFri
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgSaturdays -Value $batterAvgSat
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipSaturdays -Value $batterBabipSat
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgSundays -Value $batterAvgSun
		$obj | Add-Member -MemberType NoteProperty -Name BatterBabipSundays -Value $batterBabipSun
		#$obj | Add-Member -MemberType NoteProperty -Name BatterAvgLast10Days -Value $batterAvgLast10Days		
	}
	return $obj
}


function GetTopAvgHittersTesting($limit, $lastSeason, $gameType, $seasonStartDate, $seasonCurrDate) {	
	#$theUri = "https://statsapi.mlb.com/api/v1/stats?stats=byDateRange&group=hitting&gameType=$($gameType)&startDate=$($seasonStartDate)&endDate=$($seasonCurrDate)&limit=$($limit)&hydrate=person(stats(group=[hitting],type=[career,statSplits],sitCodes=[a,h,d,n,g,t,vlg,vdv,vl,vr,vls,vlr,vgo,vao,dsa,dsu,dmo,dtu,dwe,dth,dfr],sportId=1,season=$($lastSeason)))"
	$theUri = "https://statsapi.mlb.com/api/v1/stats?stats=byDateRange&group=hitting&gameType=$($gameType)&startDate=$($seasonStartDate)&endDate=$($seasonCurrDate)&limit=$($limit)&hydrate=person(stats(group=[hitting],type=[career]))"
	
	LogWrite "Getting Top Hitters for season as of $($theDay)..."

	$theFields = "stats"
	$getTopHitters = GetApiData $theUri $theFields

	<#
	$findSplitStats = ""
	$findSplitStats = $getTopHitters.splits[0].player.stats[1].splits[0].split.description
	if ($findSplitStats -eq "Away Games") {
		$x = 1
	} else {
		$x = 2
	}
	#>

	$theTopHittersDetails = @()
	$theTopHittersDetails = buildHitterDetailsObjectTesting $getTopHitters "Testing"
	$theFilename = "hittingLeaders_Details"	

	$hitterDetailsJson = Get-Content -Raw -Path "$($basePath)\Data\Test\$($theFilename).json" | Out-String | ConvertFrom-Json
	$theExistingData = $hitterDetailsJson.TopHitterDetails		
	$theAppendedTopHittersData = $theExistingData + $theTopHittersDetails
	$theTopHittersDetailsObj = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -Type NoteProperty -Name TopHitterDetails -Value $theAppendedTopHittersData
	$theTopHittersDetailsObj += $theRootObj
		
	$test = WriteToJsonFile "$($basePath)\Data\Test" $theFilename $theTopHittersDetailsObj
	LogWrite "File $($theFilename) was updated!"
	
		
	$theTopHittersDaily = @()
	$theTopHittersDaily = buildHitterObject $getTopHitters "Testing"
	$theFilename = "hittingLeaders_$($theDay.Replace('/',''))"
	$theTopHittersObj = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -MemberType NoteProperty -Name TopHitters -Value $theTopHittersDaily
	$theTopHittersObj += $theRootObj
	
	$test = WriteToJsonFile "$($basePath)\Data\Test" $theFilename $theTopHittersObj
	LogWrite "File $($theFilename) was created!"

	return "Done"
}

function GetTopAvgHitters($limit, $season, $gameType) {
	#Build REST GET for MLB API
	$theUri = "https://statsapi.mlb.com/api/v1/stats/leaders?leaderCategories=battingAverage&statGroup=hitting&limit=$($limit)&leaderGameTypes=$($gameType)&season=$($season)&hydrate=person(stats(group=[hitting,pitching],type=[career,statSplits],sitCodes=[a,h,d,n,g,t,vlg,vdv,vl,vr,vls,vlr,vgo,vao,dsa,dsu,dmo,dtu,dwe,dth,dfr],sportId=1)),education&sportId=1"
	
	LogWrite "Getting Top Hitters for season as of $($theDay)..."
	$theFields = "leagueLeaders"
	$getTopHitters = GetApiData $theUri $theFields

		
	$theTopHittersDaily = @()
	$theTopHittersDaily = buildHitterObject $getTopHitters ""
	$theFilename = "hittingLeaders_$($theDay.Replace('/',''))"
	$theTopHittersObj = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -MemberType NoteProperty -Name TopHitters -Value $theTopHittersDaily
	$theTopHittersObj += $theRootObj
	
	$test = WriteToJsonFile "$($basePath)\Data" $theFilename $theTopHittersObj
	LogWrite "File $($theFilename) was created!"
	
	$theTopHittersDetails = @()
	$theTopHittersDetails = buildHitterDetailsObject $getTopHitters ""
	$theFilename = "hittingLeaders_Details"	
	$hitterDetailsJson = Get-Content -Raw -Path "$($basePath)\Data\$($theFilename).json" | Out-String | ConvertFrom-Json
	# REMOVE EXISTING DATA IN PROD
		#$theExistingData = $hitterDetailsJson.TopHitterDetails		
		#$theAppendedTopHittersData = $theExistingData + $theTopHittersDetails
	$theAppendedTopHittersData = $theTopHittersDetails
	
	$theTopHittersDetailsObj = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -Type NoteProperty -Name TopHitterDetails -Value $theAppendedTopHittersData
	$theTopHittersDetailsObj += $theRootObj
		
	$test = WriteToJsonFile "$($basePath)\Data" $theFilename $theTopHittersDetailsObj
	LogWrite "File $($theFilename) was updated!"
	





	<#
	if ($startOfMonth -eq "Yes") {
		$theTopHittersDetails = buildHitterObject $getTopHitters "Yes" ""
	} else {
		$theTopHittersDetails = buildHitterObject $getTopHitters "No" ""
	}

	$theTopHitters = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -MemberType NoteProperty -Name TopHitters -Value $theTopHittersDetails
	$theTopHitters += $theRootObj 
	
	$theFilename = "hittingLeaders_$($theDay.Replace('/',''))"
	$test = WriteToJsonFile $basePath $theFilename $theTopHitters
	LogWrite "File hittingLeaders_$($theDay.Replace('/','')) was created!"
	#>
	return $theTopHitters
}


function GetHittersRecentActivity($peopleId) {
	#Build REST GET for MLB API
	$season = "2018"
	$startDate = "03/29/$season".Replace("/","%2F")
	$endDate = "04/10/$season".Replace("/","%2F")
	$gameType = "R"
	$theUri = "https://statsapi.mlb.com/api/v1/people/$($peopleId)/stats?stats=byDateRange&group=hitting&gameType=$($gameType)&season=$($season)&startDate=$($startDate)&endDate=$($endDate)&sportId=1"
	#$theFields = "stats.split.stat.avg"
	$theFields = "stats"
	
	$getTopHittersRecentActivity = GetApiData $theUri $theFields
	$recentAvg = $getTopHittersRecentActivity.splits[0].stat.avg

	return $recentAvg
}


function GetTopAvgOverTimeframe() {
	#Build REST GET for MLB API
	$limit = "10"
	$season = "2018"
	$startDate = "03/29/$season".Replace("/","%2F")
	$endDate = "04/10/$season".Replace("/","%2F")
	$gameType = "R"
	$theUri = "https://statsapi.mlb.com/api/v1/stats?stats=byDateRange&group=hitting&gameType=$($gameType)&season=$($season)&startDate=$($startDate)&endDate=$($endDate)&limit=$($limit)&sportId=1"

	$theFields = "stats"
	$getTopHitters = GetApiData $theUri $theFields
	$batterId = $getTopHittersRecentActivity.splits[0].player.id
	$batterName = $getTopHittersRecentActivity.splits[0].player.fullName
	$recentAvg = $getTopHittersRecentActivity.splits[0].stat.avg

	

	$theTopHitters = buildHitterObject $getTopHitters "Yes" ""

	return $theTopHitters
}

function GetHitterList($jsonFile) {
	$jsonObject = Get-Content $jsonFile | Out-String | ConvertFrom-Json

}
