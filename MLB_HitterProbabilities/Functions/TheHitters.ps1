#
# TheHitters.ps1
#

function buildHitterObject($getTopHitters) {
	$theTopHitters = @()
	for ($z=0; $z -lt $getTopHitters.leaders.length; $z++){
		$batterID = $getTopHitters.leaders[$z].person.id
		$batterName = $getTopHitters.leaders[$z].person.fullname
		$batterTeamID = $getTopHitters.leaders[$z].team.id
		$batterTeamName = $getTopHitters.leaders[$z].team.name
		$batterRank = $getTopHitters.leaders[$z].rank
		$batterAverage = $getTopHitters.leaders[$z].value
		$batterSide = $getTopHitters.leaders[$z].person.batSide.description
		$batterAvgAway = $getTopHitters.leaders[$z].person.stats[$x].splits[0].stat.avg
		$batterAvgHome = $getTopHitters.leaders[$z].person.stats[$x].splits[10].stat.avg
		$batterAvgDay = $getTopHitters.leaders[$z].person.stats[$x].splits[1].stat.avg
		$batterAvgNight = $getTopHitters.leaders[$z].person.stats[$x].splits[11].stat.avg
		$batterAvgMon = $getTopHitters.leaders[$z].person.stats[$x].splits[3].stat.avg
		$batterAvgTue = $getTopHitters.leaders[$z].person.stats[$x].splits[7].stat.avg
		$batterAvgWed = $getTopHitters.leaders[$z].person.stats[$x].splits[8].stat.avg
		$batterAvgThu = $getTopHitters.leaders[$z].person.stats[$x].splits[6].stat.avg
		$batterAvgFri = $getTopHitters.leaders[$z].person.stats[$x].splits[2].stat.avg
		$batterAvgSat = $getTopHitters.leaders[$z].person.stats[$x].splits[4].stat.avg
		$batterAvgSun = $getTopHitters.leaders[$z].person.stats[$x].splits[5].stat.avg
		$batterAvgGrass = $getTopHitters.leaders[$z].person.stats[$x].splits[9].stat.avg
		$batterAvgTurf = $getTopHitters.leaders[$z].person.stats[$x].splits[12].stat.avg
		$batterAvgLeft = $getTopHitters.leaders[$z].person.stats[$x].splits[17].stat.avg
		$batterAvgRight = $getTopHitters.leaders[$z].person.stats[$x].splits[20].stat.avg
				
		#$batterAvgLast10Days = GetHittersRecentActivity $batterID


		#build the return object with names
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name BatterID -Value $batterID
		$obj | Add-Member -MemberType NoteProperty -Name BatterName -Value $batterName
		$obj | Add-Member -MemberType NoteProperty -Name BatterTeamID -Value $batterTeamID
		$obj | Add-Member -MemberType NoteProperty -Name BatterTeamName -Value $batterTeamName
		$obj | Add-Member -MemberType NoteProperty -Name BatterHittingSide -Value $batterSide
		$obj | Add-Member -MemberType NoteProperty -Name BatterRank -Value $batterRank
		$obj | Add-Member -MemberType NoteProperty -Name BatterCurrentAverage -Value $batterAverage
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

		$theTopHitters += $obj
	}
	return $theTopHitters
}


function GetTopAvgHitters($limit, $season, $gameType) {
	#Build REST GET for MLB API
	#$theUri = "https://statsapi.mlb.com/api/v1/stats/leaders?leaderCategories=battingAverage&statGroup=hitting&limit=$($limit)"
	#$theUri = "https://statsapi.mlb.com/api/v1/stats/leaders?leaderCategories=battingAverage&statGroup=hitting&limit=$($limit)&leaderGameTypes=$($gameType)&season=$($season)"
	$theUri = "https://statsapi.mlb.com/api/v1/stats/leaders?leaderCategories=battingAverage&statGroup=hitting&limit=$($limit)&leaderGameTypes=$($gameType)&season=$($season)&hydrate=person(stats(group=[hitting,pitching],type=[career,statSplits],sitCodes=[a,h,d,n,g,t,vlg,vdv,vl,vr,vls,vlr,vgo,vao,dsa,dsu,dmo,dtu,dwe,dth,dfr],sportId=1)),education&sportId=1"
	#$theUri = "https://statsapi.mlb.com/api/v1/stats?stats=byDateRange&group=hitting&gameType=R&season=2018&startDate=09%2F01%2F2018&endDate=09%2F15%2F2018&sportId=1"

	$theFields = "leagueLeaders"
	$getTopHitters = GetApiData $theUri $theFields

	$findSplitStats = ""
	$findSplitStats = $getTopHitters.leaders[0].person.stats[1].splits[0].split.description
	if ($findSplitStats -eq "Away Games") {
		$x = 1
	} else {
		$x = 2
	}

	$theTopHitters = buildHitterObject $getTopHitters

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

	

	$theTopHitters = buildHitterObject $getTopHitters

	return $theTopHitters
}
