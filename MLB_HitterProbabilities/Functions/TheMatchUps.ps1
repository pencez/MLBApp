#
# TheMatchups.ps1
#

Function getMatchupData($includeResultsYN) {
	#get thehitters from file
	$theHitters = Get-Content -Raw -Path "$($basePath)\Data\hittingLeaders_$($theDay.Replace('/','')).json" | Out-String | ConvertFrom-Json
	$theGameInfo = Get-Content -Raw -Path "$($basePath)\Data\pregame_$($theDay.Replace('/','')).json" | Out-String | ConvertFrom-Json

	$theMatchupData = @()
	for ($h=0; $h -lt $theHitters.TopHitters.Count; $h++) {	
		$theTeam = $theHitters.TopHitters[$h].BatterTeamID
		$theTeamName = $theHitters.TopHitters[$h].BatterTeamName
		$theBatId = $theHitters.TopHitters[$h].BatterID
		$theBatName = $theHitters.TopHitters[$h].BatterName
		$theBatAvg = $theHitters.TopHitters[$h].BatterCurrentAverage

		$theGamePk = $theGameInfo.GameInfo | where { $_.HomeTeamId -eq $theTeam } | Select -ExpandProperty GamePk
		if ($theGamePk) {
			$homeAway = "Home"
		} else {
			$theGamePk = $theGameInfo.GameInfo | where { $_.AwayTeamId -eq $theTeam } | Select -ExpandProperty GamePk
			if ($theGamePk) {
				$homeAway = "Away"
			} else {
				$theGamePk = "No Game"
			}
		}
		if ($theGamePk -ne "No Game") {
			# Get more info about the matchup
			#"GameTimeZone":  "ET", "WeatherCond":  "Cloudy", "WeatherTemp":  "45", "WeatherWind":  "14mph R To L", "VenueCity":  "Boston, MA", "VenueSite":  "Fenway Park",
			$theGameDayofWk = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameDayofWk
			if ($theGameDayofWk -eq "MON") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgMondays }
			elseif ($theGameDayofWk -eq "TUE") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgTuesdays }
			elseif ($theGameDayofWk -eq "WED") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgWednesdays }
			elseif ($theGameDayofWk -eq "THU") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgThursdays }
			elseif ($theGameDayofWk -eq "FRI") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgFridays }
			elseif ($theGameDayofWk -eq "SAT") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgSaturdays }
			elseif ($theGameDayofWk -eq "SUN") { $theBatAvgForDayofWk = $theHitters.TopHitters[$h].BatterAvgSundays }
			$theGameTime = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameTime
			$theGameAMPM = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameAMPM
			$theGameDayNight = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameDayNight
			if ($theGameDayNight -eq "Day") { $theBatAvgForDayNight = $theHitters.TopHitters[$h].BatterAvgDay }
			else { $theBatAvgForDayNight = $theHitters.TopHitters[$h].BatterAvgNight }

			if ($homeAway -eq "Home") {
				$theBatAvgHomeAway = $theHitters.TopHitters[$h].BatterAvgHome  #Get Batters AVG for when HOME
				# get Away team matchup data
				# "AwayTeamId":  "147", "AwayTeamName":  "New York Yankees", "AwayTeamWins":  "5", "AwayTeamLoss":  "6",
				$theVsPitcherId = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherId
				$theVsPitcherName = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherName
				$theVsPitcherHand = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherHand
				$theVsPitcherWins = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherWins
				$theVsPitcherLoss = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherLoss
				$theVsPitcherEra = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherEra
			} else {
				$theBatAvgHomeAway = $theHitters.TopHitters[$h].BatterAvgAway  #Get Batters AVG for when AWAY
				# get Home team matchup data
				#"HomeTeamId":  "111", "HomeTeamName":  "Boston Red Sox", "HomeTeamWins":  "9", "HomeTeamLoss":  "1",							
				$theVsPitcherId = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherId
				$theVsPitcherName = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherName
				$theVsPitcherHand = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherHand
				$theVsPitcherWins = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherWins
				$theVsPitcherLoss = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherLoss
				$theVsPitcherEra = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherEra
			}			
			if ($theVsPitcherHand -eq "R") { $theBatAvgVsHand = $theHitters.TopHitters[$h].BatterAvgToRighty }
			else { $theBatAvgVsHand = $theHitters.TopHitters[$h].BatterAvgToLefty }
			
			if ($includeResultsYN -eq "Yes") {
				# get results too
				$theUri = "https://statsapi.mlb.com/api/v1/people/$($theBatId)/stats/game/$($theGamePk)?group=hitting"
				$theFields = "stats"
				$getResultsData = GetApiData $theUri $theFields
				$resultHits = $getResultsData[0].splits[0].stat.hits
				$resultAtBats = $getResultsData[0].splits[0].stat.atbats
			}

			$theMatchupData += BuildMatchupsData
			# clear the variables for the next run in loop
			$versusArray = ("theVsPitcherId", "theVsPitcherName", "theVsPitcherHand", "theVsPitcherWins", "theVsPitcherLoss", "theVsPitcherEra")
			foreach ($Item in $versusArray) {
				Get-Variable $Item | Clear-Variable
			}
		}
	}

	
	$theMatchupInfo = @()
	$theRootObj = New-Object -TypeName psobject
	$theRootObj| Add-Member -MemberType NoteProperty -Name MatchupInfo -Value $theMatchupData
	$theMatchupInfo += $theRootObj

	WriteToJsonFile $basePath "matchups_$($theDay.Replace('/',''))" $theMatchupInfo
	LogWrite "File matchups_$($theDay.Replace('/','')) was created!"

	# Temporary return to CSV format for excel
	#$theMatchupInfo.MatchupInfo | Out-String | ConvertFrom-Json | Export-CSV "$($basePath)\Data\Results.csv" -NoTypeInformation

	return $theMatchupData
}


function BuildMatchupsData() {

	$obj = New-Object -TypeName psobject
	$obj | Add-Member -MemberType NoteProperty -Name BatterId -Value $theBatId
	$obj | Add-Member -MemberType NoteProperty -Name Batter -Value $theBatName
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvg -Value $theBatAvg
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeamId -Value $theTeam
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeam -Value $theTeamName
	$obj | Add-Member -MemberType NoteProperty -Name HomeOrAway -Value $homeAway
	$obj | Add-Member -MemberType NoteProperty -Name GamePk -Value $theGamePk
	$obj | Add-Member -MemberType NoteProperty -Name GameDate -Value $theDay
	$obj | Add-Member -MemberType NoteProperty -Name GameTime -Value $theGameTime
	$obj | Add-Member -MemberType NoteProperty -Name GameAMPM -Value $theGameAMPM
	$obj | Add-Member -MemberType NoteProperty -Name GameDayofWk -Value $theGameDayofWk
	$obj | Add-Member -MemberType NoteProperty -Name GameDayNight -Value $theGameDayNight
	#$obj | Add-Member -MemberType NoteProperty -Name GameTimeZone -Value $theGameTimeZone
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherId -Value $theVsPitcherId
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherName -Value $theVsPitcherName
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherHand -Value $theVsPitcherHand
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherWins -Value $theVsPitcherWins
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherLoss -Value $theVsPitcherLoss
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherEra -Value $theVsPitcherEra
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgHomeAway -Value $theBatAvgHomeAway
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgForDayofWk -Value $theBatAvgForDayofWk
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgForDayNight -Value $theBatAvgForDayNight
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgVsHand -Value $theBatAvgVsHand
	if ($includeResultsYN -eq "Yes") {
		$obj | Add-Member -MemberType NoteProperty -Name BatterResultAtBats -Value $resultAtBats
		$obj | Add-Member -MemberType NoteProperty -Name BatterResultHits -Value $resultHits
	}

	return $obj
}