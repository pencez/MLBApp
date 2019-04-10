#
# TheGames.ps1
#	get team info - home/away, wins/losses
#	get location - home/away, dome/open, grass/turf
#	get date/time - day of week, day/night
#	get pitcher info
#		wins/losses, ERA
#		throws left/right
#

function GetGameInfo($gameType, $date) {
	$gamePrePost = "Pre"
	if ($testing -eq 1) {
		$teamFile = Get-Content -Raw -Path "$($basePath)\Data\Test\teamInfo.json" | Out-String | ConvertFrom-Json
		$pregameFilePath = "$($basePath)\Data\Test"
	} else {
		$teamFile = Get-Content -Raw -Path "$($basePath)\Data\teamInfo.json" | Out-String | ConvertFrom-Json
		$pregameFilePath = "$($basePath)\Data"
	}
	#$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&startDate=$($startDate)&endDate=$($endDate)"
	$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&date=$($date)"	
	$theFields = "dates"
	$getGameData = GetApiData $theUri $theFields
	
	LogWrite "Getting pregame_$($theDay.Replace('/','')) file started..."

	$theGameData = @()
	foreach($date in $getGameData) {
		$gameDate = $date.date
		$dateStamp = $gameDate.replace('-','')
		foreach($game in $date.games) {
			$gamePk = $game.gamePk
			$feedUri = "https://statsapi.mlb.com/api/v1/game/$($gamePk)/feed/live?timecode=$($dateStamp)_010000"
			$gameDetails = GetGameDetails $feedUri
			$theGameData += $gameDetails
		}
		
		# create pregame json object structure before saving as a file
		$theGameInfo = @()
		$theRootObj = New-Object -TypeName psobject
		$theRootObj| Add-Member -MemberType NoteProperty -Name GameInfo -Value $theGameData
		$theGameInfo += $theRootObj

		WriteToJsonFile $pregameFilePath "pregame_$($theDay.Replace('/',''))" $theGameInfo
		LogWrite "File pregame_$($theDay.Replace('/','')) was created!"
	}
}

function updateTeamRecords($gameType, $date) {	
	# load the team file
	$teamFile = Get-Content -Raw -Path "$($basePath)\Data\teamInfo.json" | Out-String | ConvertFrom-Json
	$currentDay = [datetime]::parseexact($date, 'MM/dd/yyyy', $null)
	$yesterdayDate = $currentDay.AddDays(-$(1)).ToString("MM/dd/yyyy")
	$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&date=$($yesterdayDate)"
	$theFields = "dates"
	$getGames = GetApiData $theUri $theFields
	
	LogWrite "Updating Team records..."
	
	$theGameData = @()
	foreach($yesterdayDate in $getGames) {
		$gameDate = $yesterdayDate.date
		$dateStamp = $gameDate.replace('-','')
		foreach($game in $yesterdayDate.games) {
			$gamePk = $game.gamePk
			# get game status to see if "F" Final then we track the team results
			$gameStatus = $game | where { $_.gamePk -eq $gamePk } | Select-Object -Property @{ Name="codedGameState"; Expression={$game.status.codedGameState}} | Select -ExpandProperty codedGameState
			if ($gameStatus -eq "F") {				
				# find and update content
				$gameAwayTmId = $game.teams.away.team.id
				$gameAwayTmNm = $game.teams.away.team.name
				$gameAwayTmWs = $game.teams.away.leagueRecord.wins
				$gameAwayTmLs = $game.teams.away.leagueRecord.losses
				$gameAwayWinTF = $game.teams.away.isWinner
				$gameHomeTmId = $game.teams.home.team.id
				$gameHomeTmNm = $game.teams.home.team.name
				$gameHomeTmWs = $game.teams.home.leagueRecord.wins
				$gameHomeTmLs = $game.teams.home.leagueRecord.losses
				$gameHomeWinTF = $game.teams.home.isWinner
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameAwayTmId) { $_.TeamWins = "$($gameAwayTmWs)" } }				
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameAwayTmId) { $_.TeamLoss = "$($gameAwayTmLs)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameAwayTmId) { $_.LastGameWin = "$($gameAwayWinTF)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameHomeTmId) { $_.TeamWins = "$($gameHomeTmWs)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameHomeTmId) { $_.TeamLoss = "$($gameHomeTmLs)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameHomeTmId) { $_.LastGameWin = "$($gameHomeWinTF)" } }
			}
		}
		# save the updated team file with game results W/L
		$teamFile | ConvertTo-Json  | Set-Content "$($basePath)\Data\teamInfo.json"

		LogWrite "Team records updated!"
	}
}

function GetGameResults($gameType, $date) {
	$gamePrePost = "Post"
	if ($testing -eq 1) {
		$teamFile = Get-Content -Raw -Path "$($basePath)\Data\Test\teamInfo.json" | Out-String | ConvertFrom-Json
		$postgameFilePath = "$($basePath)\Data\Test"
	} else {
		$teamFile = Get-Content -Raw -Path "$($basePath)\Data\teamInfo.json" | Out-String | ConvertFrom-Json
		$postgameFilePath = "$($basePath)\Data"
	}
	#$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&startDate=$($startDate)&endDate=$($endDate)"
	$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&date=$($date)"	
	$theFields = "dates"
	$getGames = GetApiData $theUri $theFields
	
	LogWrite "Getting postgame_$($theDay.Replace('/','')) file started..."

	$theGameData = @()
	foreach($date in $getGames) {
		$gameDate = $date.date
		$dateStamp = $gameDate.replace('-','')
		foreach($game in $date.games) {
			$gamePk = $game.gamePk
			# get game status to see if "F" Final then we track the team results
			$gameStatus = $game | where { $_.gamePk -eq $gamePk } | Select-Object -Property @{ Name="codedGameState"; Expression={$game.status.codedGameState}} | Select -ExpandProperty codedGameState
			if ($gameStatus -eq "F") {
				$gameAwayTmId = $game.teams.away.team.id
				$gameAwayTmNm = $game.teams.away.team.name
				$gameAwayTmWs = $game.teams.away.leagueRecord.wins
				$gameAwayTmLs = $game.teams.away.leagueRecord.losses
				$gameAwayWinTF = $game.teams.away.isWinner
				$gameHomeTmId = $game.teams.home.team.id
				$gameHomeTmNm = $game.teams.home.team.name
				$gameHomeTmWs = $game.teams.home.leagueRecord.wins
				$gameHomeTmLs = $game.teams.home.leagueRecord.losses
				$gameHomeWinTF = $game.teams.home.isWinner
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameAwayTmId) { $_.TeamWins = "$($gameAwayTmWs)" } }				
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameAwayTmId) { $_.TeamLoss = "$($gameAwayTmLs)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameAwayTmId) { $_.LastGameWin = "$($gameAwayWinTF)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameHomeTmId) { $_.TeamWins = "$($gameHomeTmWs)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameHomeTmId) { $_.TeamLoss = "$($gameHomeTmLs)" } }
				$teamFile.TeamsData | % { if ($_.TeamId -eq $gameHomeTmId) { $_.LastGameWin = "$($gameHomeWinTF)" } }
			}
			$feedUri = "https://statsapi.mlb.com/api/v1/game/$($gamePk)/feed/live?timecode=$($dateStamp)_235900"
			# call function below
			$gameDetails = GetGameDetails $feedUri
			$theGameData += $gameDetails
		}

		# save the updated team file with game results W/L
		$teamFile | ConvertTo-Json  | Set-Content "$($basePath)\Data\teamInfo.json"
		
		# create postgame json object structure before saving as a file
		$theGameResults = @()
		$theRootObj = New-Object -TypeName psobject
		$theRootObj| Add-Member -MemberType NoteProperty -Name GameResults -Value $theGameData
		$theGameResults += $theRootObj

		WriteToJsonFile $postgameFilePath "postgame_$($theDay.Replace('/',''))" $theGameResults
		LogWrite "File postgame_$($theDay.Replace('/','')) was created!"
	}
}

function GetGameDetails($feedUri) {	
	# run API for GameData
	$theFields = "gameData"
	$getGameData = GetApiData $feedUri $theFields
	# re-run API for LiveData
	$theFields = "liveData"
	$getLiveData = GetApiData $feedUri $theFields
		
	$gameDayofWk = (Get-Date $theDay -UFormat %a).ToUpper()
	$gameTime = $getGameData.datetime.time
	$gameAmPm = $getGameData.datetime.ampm
	$gameDayNight = $getGameData.datetime.dayNight
	if ($testing -eq 1) {
		$gameTimeZone = $getGameData.dateTime.timeZone
	} else {
		$gameTimeZone = $getGameData.venue.timeZone.tz
	}
	$weatherCond = $getGameData.weather.condition
	$weatherTemp = $getGameData.weather.temp
	$weatherWind = $getGameData.weather.wind
	if ($testing -eq 1) {
		$venueCity = $getGameData.venue.location
	} else {
		$venueCity = $getGameData.venue.location.city
	}
	$venueSite = $getGameData.venue.name
	
	#away team details	
	if ($testing -eq 1) {
		$awayTeamId = $getGameData.teams.away.teamId
		$awayTeam = $getGameData.teams.away.name.full
		$awayTeamW = $getGameData.teams.away.record.wins
		$awayTeamL = $getGameData.teams.away.record.losses
		$awayPitcherId = $getLiveData.boxscore.teams.away.pitchers[0]
		$awayPlayerPath = $getLiveData.boxscore.teams.away.players
		$awayPlayerIDnId = "ID" + $awayPitcherId
		$awayPlayerById = $awayPlayerPath.$awayPlayerIDnId		
		$awayPitcherName = $awayPlayerById.name.first + " " + $awayPlayerById.name.last 
		$awayPitcherWins = $awayPlayerById.seasonStats.pitching.wins
		$awayPitcherLoss = $awayPlayerById.seasonStats.pitching.losses
		$awayPitcherEra = $awayPlayerById.seasonStats.pitching.era
	} else {
		$awayTeamId = $getGameData.teams.away.id
		$awayTeam = $getGameData.teams.away.name
		$awayTeamW = $getGameData.teams.away.record.wins
		$awayTeamL = $getGameData.teams.away.record.losses
		$awayPitcherId = $getGameData.probablePitchers.away.id
		$awayPitcherName = $getGameData.probablePitchers.away.fullName
		$awayPlayerPath = $getLiveData.boxscore.teams.away.players
		$awayPlayerIDnId = "ID" + $awayPitcherId
		$awayPlayerById = $awayPlayerPath.$awayPlayerIDnId
		$awayPitcherWins = $awayPlayerById.seasonStats.pitching.wins
		$awayPitcherLoss = $awayPlayerById.seasonStats.pitching.losses
		$awayPitcherEra = $awayPlayerById.seasonStats.pitching.era
	}
	$theFields = "people"
	if ($awayPitcherId) {
		$feedUri = "https://statsapi.mlb.com/api/v1/people/$($awayPitcherId)"
		$getAwayPitcher = GetApiData $feedUri $theFields
	}	
	$awayPitcherRightLeft = $getAwayPitcher.pitchHand.code
	
	#home team details
	if ($testing -eq 1) {
		$homeTeamId = $getGameData.teams.home.teamId
		$homeTeam = $getGameData.teams.home.name.full
		$homeTeamW = $getGameData.teams.home.record.wins
		$homeTeamL = $getGameData.teams.home.record.losses
		$homePitcherId = $getLiveData.boxscore.teams.home.pitchers[0]
		$homePlayerPath = $getLiveData.boxscore.teams.home.players
		$homePlayerIDnId = "ID" + $homePitcherId
		$homePlayerById = $homePlayerPath.$homePlayerIDnId		
		$homePitcherName = $homePlayerById.name.first + " " + $homePlayerById.name.last 
		$homePitcherWins = $homePlayerById.seasonStats.pitching.wins
		$homePitcherLoss = $homePlayerById.seasonStats.pitching.losses
		$homePitcherEra = $homePlayerById.seasonStats.pitching.era
	} else {
		$homeTeamId = $getGameData.teams.home.id
		$homeTeam = $getGameData.teams.home.name
		$homeTeamW = $getGameData.teams.home.record.wins
		$homeTeamL = $getGameData.teams.home.record.losses
		$homePitcherId = $getGameData.probablePitchers.home.id
		$homePitcherName = $getGameData.probablePitchers.home.fullName
		$homePlayerPath = $getLiveData.boxscore.teams.home.players
		$homePlayerIDnId = "ID" + $homePitcherId
		$homePlayerById = $homePlayerPath.$homePlayerIDnId
		$homePitcherWins = $homePlayerById.seasonStats.pitching.wins
		$homePitcherLoss = $homePlayerById.seasonStats.pitching.losses
		$homePitcherEra = $homePlayerById.seasonStats.pitching.era
	}
	$theFields = "people"
	if ($homePitcherId) {
		$feedUri = "https://statsapi.mlb.com/api/v1/people/$($homePitcherId)"
		$getHomePitcher = GetApiData $feedUri $theFields
	}
	$homePitcherRightLeft = $getHomePitcher.pitchHand.code	

	
	return BuildGamesData
}

function BuildGamesData() {
	$obj = New-Object -TypeName psobject
	$obj | Add-Member -MemberType NoteProperty -Name GamePk -Value $gamePk
	$obj | Add-Member -MemberType NoteProperty -Name GameDate -Value $gameDate
	$obj | Add-Member -MemberType NoteProperty -Name GameTime -Value $gameTime
	$obj | Add-Member -MemberType NoteProperty -Name GameAMPM -Value $gameAmPm
	$obj | Add-Member -MemberType NoteProperty -Name GameDayofWk -Value $gameDayofWk
	$obj | Add-Member -MemberType NoteProperty -Name GameDayNight -Value $gameDayNight
	$obj | Add-Member -MemberType NoteProperty -Name GameTimeZone -Value $gameTimeZone
	$obj | Add-Member -MemberType NoteProperty -Name WeatherCond -Value $weatherCond
	$obj | Add-Member -MemberType NoteProperty -Name WeatherTemp -Value $weatherTemp
	$obj | Add-Member -MemberType NoteProperty -Name WeatherWind -Value $weatherWind
	$obj | Add-Member -MemberType NoteProperty -Name VenueCity -Value $venueCity
	$obj | Add-Member -MemberType NoteProperty -Name VenueSite -Value $venueSite
	$obj | Add-Member -MemberType NoteProperty -Name AwayTeamId -Value $awayTeamId
	$obj | Add-Member -MemberType NoteProperty -Name AwayTeamName -Value $awayTeam
	$obj | Add-Member -MemberType NoteProperty -Name AwayTeamWins -Value $awayTeamW
	$obj | Add-Member -MemberType NoteProperty -Name AwayTeamLoss -Value $awayTeamL
	if ($gamePrePost -eq "Pre") {
		$awayTeamWinLast = $teamFile.TeamsData | where { $_.TeamId -eq $awayTeamId } | Select -ExpandProperty LastGameWin
		$obj | Add-Member -MemberType NoteProperty -Name AwayTeamWinLast -Value $awayTeamWinLast
	}
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherId -Value $awayPitcherId
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherName -Value $awayPitcherName
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherHand -Value $awayPitcherRightLeft
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherWins -Value $awayPitcherWins
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherLoss -Value $awayPitcherLoss
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherEra -Value $awayPitcherEra
	$obj | Add-Member -MemberType NoteProperty -Name HomeTeamId -Value $homeTeamId
	$obj | Add-Member -MemberType NoteProperty -Name HomeTeamName -Value $homeTeam
	$obj | Add-Member -MemberType NoteProperty -Name HomeTeamWins -Value $homeTeamW
	$obj | Add-Member -MemberType NoteProperty -Name HomeTeamLoss -Value $homeTeamL
	if ($gamePrePost -eq "Pre") {
		$homeTeamWinLast = $teamFile.TeamsData | where { $_.TeamId -eq $homeTeamId } | Select -ExpandProperty LastGameWin
		$obj | Add-Member -MemberType NoteProperty -Name HomeTeamWinLast -Value $homeTeamWinLast
	}
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherId -Value $homePitcherId
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherName -Value $homePitcherName
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherHand -Value $homePitcherRightLeft
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherWins -Value $homePitcherWins
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherLoss -Value $homePitcherLoss
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherEra -Value $homePitcherEra

	return $obj
}