#
# TheHitters.ps1
#


function buildHitterDetailsObject($getTopHitters, $testing) {
	$theHittersDetails = Get-Content -Raw -Path "$($basePath)\Data\hittingLeaders_Details.json" | Out-String | ConvertFrom-Json
	$theBatterList = @()
	foreach($theBatters in $theHittersDetails.TopHitterDetails.BatterID ) { 
		$theBatterList += $theBatters
	}

	$theTopHittersDetails = @()
	for ($z=0; $z -lt $getTopHitters.splits.length; $z++){
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
			$batterTeamID = $getTopHitters.splits[$z].team.id
			$batterTeamName = $getTopHitters.splits[$z].team.name	
			$batterCareerAvg = $getTopHitters.splits[$z].player.stats[$($x - 1)].splits[0].stat.avg
			$batterCareerBabip = $getTopHitters.splits[$z].player.stats[$($x - 1)].splits[0].stat.babip
			# Should we get BABIP for Home vs Away???
			$batterAvgAway = $getTopHitters.splits[$z].player.stats[$x].splits[0].stat.avg
			$batterAvgHome = $getTopHitters.splits[$z].player.stats[$x].splits[10].stat.avg
			$batterAvgDay = $getTopHitters.splits[$z].player.stats[$x].splits[1].stat.avg
			$batterAvgNight = $getTopHitters.splits[$z].player.stats[$x].splits[11].stat.avg
			$batterAvgMon = $getTopHitters.splits[$z].player.stats[$x].splits[3].stat.avg
			$batterAvgTue = $getTopHitters.splits[$z].player.stats[$x].splits[7].stat.avg
			$batterAvgWed = $getTopHitters.splits[$z].player.stats[$x].splits[8].stat.avg
			$batterAvgThu = $getTopHitters.splits[$z].player.stats[$x].splits[6].stat.avg
			$batterAvgFri = $getTopHitters.splits[$z].player.stats[$x].splits[2].stat.avg
			$batterAvgSat = $getTopHitters.splits[$z].player.stats[$x].splits[4].stat.avg
			$batterAvgSun = $getTopHitters.splits[$z].player.stats[$x].splits[5].stat.avg
			$batterAvgGrass = $getTopHitters.splits[$z].player.stats[$x].splits[9].stat.avg
			$batterAvgTurf = $getTopHitters.splits[$z].player.stats[$x].splits[12].stat.avg
			$batterAvgLeft = $getTopHitters.splits[$z].player.stats[$x].splits[17].stat.avg
			$batterAvgRight = $getTopHitters.splits[$z].player.stats[$x].splits[20].stat.avg
			
			# Build the json record with player details
			$theTopHittersDetails += buildTopHitterObject $getDetailsYN
		}
	}
	
	return $theTopHittersDetails
}

function buildHitterObject($getTopHitters, $testing) {
		
	
	$theTopHitters = @()
	if ($testing -eq "") {
		for ($z=0; $z -lt $getTopHitters.leaders.length; $z++){
			$batterID = $getTopHitters.leaders[$z].person.id
			$batterName = $getTopHitters.leaders[$z].person.fullname
			$batterTeamID = $getTopHitters.leaders[$z].team.id
			$batterTeamName = $getTopHitters.leaders[$z].team.name
			$batterRank = $getTopHitters.leaders[$z].rank
			$batterAverage = $getTopHitters.leaders[$z].value
					
			$theTopHittersDetails += buildTopHitterObject "No"
		}
	} else {
		# this is my testing area
		for ($z=0; $z -lt $getTopHitters.splits.length; $z++){
			$batterID = $getTopHitters.splits[$z].player.id
			$batterName = $getTopHitters.splits[$z].player.fullname
			$batterTeamID = $getTopHitters.splits[$z].team.id
			$batterTeamName = $getTopHitters.splits[$z].team.name
			$batterSide = $getTopHitters.splits[$z].player.batSide.description
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
	if ($getDetailsYN -eq "Yes") {		 
		$obj | Add-Member -MemberType NoteProperty -Name BatterCareerAvg -Value $batterCareerAvg 
		$obj | Add-Member -MemberType NoteProperty -Name BatterCareerBabip -Value $batterCareerBabip
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgHome -Value $batterAvgHome
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgAway -Value $batterAvgAway
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgDay -Value $batterAvgDay
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgNight -Value $batterAvgNight
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgGrass -Value $batterAvgGrass
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgTurf -Value $batterAvgTurf
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgToLefty -Value $batterAvgLeft
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgToRighty -Value $batterAvgRight
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgMondays -Value $batterAvgMon
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgTuesdays -Value $batterAvgTue
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgWednesdays -Value $batterAvgWed
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgThursdays -Value $batterAvgThu
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgFridays -Value $batterAvgFri
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgSaturdays -Value $batterAvgSat
		$obj | Add-Member -MemberType NoteProperty -Name BatterAvgSundays -Value $batterAvgSun
		#$obj | Add-Member -MemberType NoteProperty -Name BatterAvgLast10Days -Value $batterAvgLast10Days		
	} else {		
		$obj | Add-Member -MemberType NoteProperty -Name BatterHittingSide -Value $batterSide
		$obj | Add-Member -MemberType NoteProperty -Name BatterRank -Value $batterRank
		$obj | Add-Member -MemberType NoteProperty -Name BatterCurrentAverage -Value $batterAverage
		$obj | Add-Member -MemberType NoteProperty -Name BatterCurrentBABIP -Value $batterBABIP
	}
	return $obj
}


function GetTopAvgHittersTesting($limit, $lastSeason, $gameType, $seasonStartDate, $seasonCurrDate) {	
	$theUri = "https://statsapi.mlb.com/api/v1/stats?stats=byDateRange&group=hitting&gameType=$($gameType)&startDate=$($seasonStartDate)&endDate=$($seasonCurrDate)&limit=$($limit)&hydrate=person(stats(group=[hitting,pitching],type=[career,statSplits],sitCodes=[a,h,d,n,g,t,vlg,vdv,vl,vr,vls,vlr,vgo,vao,dsa,dsu,dmo,dtu,dwe,dth,dfr],sportId=1,season=$($lastSeason)))"
	
	LogWrite "Getting Top Hitters for season as of $($theDay)..."

	$theFields = "stats"
	$getTopHitters = GetApiData $theUri $theFields

	$findSplitStats = ""
	$findSplitStats = $getTopHitters.splits[0].player.stats[1].splits[0].split.description
	if ($findSplitStats -eq "Away Games") {
		$x = 1
	} else {
		$x = 2
	}
	
	$theTopHittersDetails = @()
	$theTopHittersDetails = buildHitterDetailsObject $getTopHitters "Testing"
	$theFilename = "hittingLeaders_Details"	

	$hitterDetailsJson = Get-Content -Raw -Path "$($basePath)\Data\$($theFilename).json" | Out-String | ConvertFrom-Json
	$theExistingData = $hitterDetailsJson.TopHitterDetails		
	$theAppendedTopHittersData = $theExistingData + $theTopHittersDetails
	$theTopHittersDetailsObj = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -Type NoteProperty -Name TopHitterDetails -Value $theAppendedTopHittersData
	$theTopHittersDetailsObj += $theRootObj
		
	$test = WriteToJsonFile $basePath $theFilename $theTopHittersDetailsObj
	LogWrite "File $($theFilename) was updated!"
	
		
	$theTopHittersDaily = @()
	$theTopHittersDaily = buildHitterObject $getTopHitters "Testing"
	$theFilename = "hittingLeaders_$($theDay.Replace('/',''))"
	$theTopHittersObj = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj | Add-Member -MemberType NoteProperty -Name TopHitters -Value $theTopHittersDaily
	$theTopHittersObj += $theRootObj
	
	$test = WriteToJsonFile $basePath $theFilename $theTopHittersObj
	LogWrite "File $($theFilename) was created!"

	return "Done"
}

function GetTopAvgHitters($limit, $season, $gameType) {
	#Build REST GET for MLB API
	$theUri = "https://statsapi.mlb.com/api/v1/stats/leaders?leaderCategories=battingAverage&statGroup=hitting&limit=$($limit)&leaderGameTypes=$($gameType)&season=$($season)&hydrate=person(stats(group=[hitting,pitching],type=[career,statSplits],sitCodes=[a,h,d,n,g,t,vlg,vdv,vl,vr,vls,vlr,vgo,vao,dsa,dsu,dmo,dtu,dwe,dth,dfr],sportId=1)),education&sportId=1"
	
	$theFields = "leagueLeaders"
	$getTopHitters = GetApiData $theUri $theFields

	$findSplitStats = ""
	$findSplitStats = $getTopHitters.leaders[0].person.stats[1].splits[0].split.description
	if ($findSplitStats -eq "Away Games") {
		$x = 1
	} else {
		$x = 2
	}

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
