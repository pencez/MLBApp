#
# theResults.ps1
#
Function getResultsData() {
	# Use if you need to override the defualt of the previous day	
	$theDay = (Get-Date).AddDays(-1).ToString("MM/dd/yyyy")
	$theDay = "07/02/2019"
	
	#get thehitters from file
	if ($testing -eq 1) {
		$matchupFilePath = "$($basePath)\Data\Test"
	} else {
		$matchupFilePath = "$($basePath)\Data"
	}
	$theMatchups = Get-Content -Raw -Path "$($matchupFilePath)\matchups_$($theDay.Replace('/','')).json" | Out-String | ConvertFrom-Json
	LogWrite "Opened matchups file for date: $theDay!"
	
	
	#$theMatchupData = @()
	for ($h=0; $h -lt $theMatchups.MatchupInfo.Count; $h++) {
		$theGameId = $theMatchups.MatchupInfo[$h].GamePk
		$theBatterId = $theMatchups.MatchupInfo[$h].BatterId
		$theBatterNm = $theMatchups.MatchupInfo[$h].Batter

		# get hitting results from game
		$theUri = "https://statsapi.mlb.com/api/v1/people/$($theBatterId)/stats/game/$($theGameId)?group=hitting"
		$theFields = "stats"
		$getResultsData = GetApiData $theUri $theFields
		if ($getResultsData) {
			$resultHits = $getResultsData[0].splits[0].stat.hits
			$resultAtBats = $getResultsData[0].splits[0].stat.atbats
		} else {
			$resultHits = "?"
			$resultAtBats = "?"
		}
		
		$theMatchups.MatchupInfo[$h] | Add-Member -MemberType NoteProperty -Name BatterResultAtBats -Value $resultAtBats
		$theMatchups.MatchupInfo[$h] | Add-Member -MemberType NoteProperty -Name BatterResultHits -Value $resultHits
	
	}

	
	

	WriteToJsonFile "$($matchupFilePath)\" "matchups_$($theDay.Replace('/',''))" $theMatchups
	LogWrite "File matchups_$($theDay.Replace('/','')), WITH RESULTS was created!"
	
	# Copy the matchups file to the webapp
	Copy-Item "$($basePath)\Data\matchups_$($theDay.Replace('/','')).json" -Destination "$($webPath)\AppData\" -Force
	LogWrite "Matchup file copied to web app"

}