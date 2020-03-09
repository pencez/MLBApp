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
		$awayPitcherWalks = $awayPlayerById.seasonStats.pitching.baseOnBalls
		$awayPitcherHits = $awayPlayerById.seasonStats.pitching.hits
		$awayPitcherIP = $awayPlayerById.seasonStats.pitching.inningsPitched
		$awayPitcherWHIP = [math]::round( $(($awayPitcherWalks + $awayPitcherHits) / $awayPitcherIP), 2).toString("##.##")
		$awayPitcherH9IP = [math]::round( $(($awayPitcherHits * 9)/$awayPitcherIP), 2).toString("##.##") #not exact due to partial innings not included
	} else {
		$awayTeamId = $getGameData.teams.away.id
		$awayTeamId = $getGameData.teams.away.teamID #2018 - added 2/10/20
		$awayTeam = $getGameData.teams.away.name
		$awayTeamW = $getGameData.teams.away.record.wins
		$awayTeamL = $getGameData.teams.away.record.losses
		$awayPitcherId = $getGameData.probablePitchers.away.id
		$awayPitcherId = $getLiveData.boxscore.teams.away.pitchers[0] #2018 - added 2/10/20
		$awayPitcherName = $getGameData.probablePitchers.away.fullName
		$awayPlayerPath = $getLiveData.boxscore.teams.away.players
		$awayPlayerIDnId = "ID" + $awayPitcherId		
		$awayPlayerById = $awayPlayerPath.$awayPlayerIDnId #2018 - added 2/10/20
		$awayPitcherName = $awayPlayerById.name.first + " " + $awayPlayerById.name.last #2018 - added 2/10/20
		$awayPitcherWins = $awayPlayerById.seasonStats.pitching.wins
		$awayPitcherLoss = $awayPlayerById.seasonStats.pitching.losses
		$awayPitcherEra = $awayPlayerById.seasonStats.pitching.era
		$awayPitcherWalks = $awayPlayerById.seasonStats.pitching.baseOnBalls
		$awayPitcherHits = $awayPlayerById.seasonStats.pitching.hits
		$awayPitcherIP = $awayPlayerById.seasonStats.pitching.inningsPitched
		#$awayPitcherWHIP = [math]::round( $(($awayPitcherWalks + $awayPitcherHits) / $awayPitcherIP), 2).toString("##.##")
		#$awayPitcherH9IP = [math]::round( $(($awayPitcherHits * 9)/$awayPitcherIP), 2).toString("##.##") #not exact due to partial innings not included
		$awayPitcherWHIP = [math]::round( $(([int]$awayPitcherWalks + [int]$awayPitcherHits) / $awayPitcherIP), 2).toString("##.##")
		$awayPitcherH9IP = [math]::round( $(([int]$awayPitcherHits * 9)/$awayPitcherIP), 2).toString("##.##") #not exact due to partial innings not included
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
		$homeTeamId = $getGameData.teams.home.teamID #2018 - added 2/10/20
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
		$homePitcherHits = $homePlayerById.seasonStats.pitching.hits
		$homePitcherWalks = $homePlayerById.seasonStats.pitching.baseOnBalls
		$homePitcherIP = $homePlayerById.seasonStats.pitching.inningsPitched
		$homePitcherWHIP = [math]::round( $(($homePitcherWalks + $homePitcherHits) / $homePitcherIP), 2).toString("##.##")
		$homePitcherH9IP = [math]::round( $(($homePitcherHits * 9)/$homePitcherIP), 2).toString("##.##") #not exact due to partial innings not included
	} else {
		$homeTeamId = $getGameData.teams.home.id
		$homeTeam = $getGameData.teams.home.name
		$homeTeamW = $getGameData.teams.home.record.wins
		$homeTeamL = $getGameData.teams.home.record.losses
		$homePitcherId = $getGameData.probablePitchers.home.id
		$homePitcherName = $getGameData.probablePitchers.home.fullName				
		$homePitcherId = $getLiveData.boxscore.teams.home.pitchers[0] #2018 - added 2/10/20
		$homePlayerPath = $getLiveData.boxscore.teams.home.players
		$homePlayerIDnId = "ID" + $homePitcherId
		$homePlayerById = $homePlayerPath.$homePlayerIDnId
		$homePitcherName = $homePlayerById.name.first + " " + $homePlayerById.name.last #2018 - added 2/10/20
		$homePitcherWins = $homePlayerById.seasonStats.pitching.wins
		$homePitcherLoss = $homePlayerById.seasonStats.pitching.losses
		$homePitcherEra = $homePlayerById.seasonStats.pitching.era
		$homePitcherWalks = $homePlayerById.seasonStats.pitching.baseOnBalls
		$homePitcherHits = $homePlayerById.seasonStats.pitching.hits
		$homePitcherIP = $homePlayerById.seasonStats.pitching.inningsPitched
		#$homePitcherWHIP = [math]::round( $(($homePitcherWalks + $homePitcherHits) / $homePitcherIP), 2).toString("##.##")
		#$homePitcherH9IP = [math]::round( $(($homePitcherHits * 9)/$homePitcherIP), 2).toString("##.##") #not exact due to partial innings not included
		$homePitcherWHIP = [math]::round( $(([int]$homePitcherWalks + [int]$homePitcherHits) / $homePitcherIP), 2).toString("##.##")
		$homePitcherH9IP = [math]::round( $(([int]$homePitcherHits * 9)/$homePitcherIP), 2).toString("##.##") #not exact due to partial innings not included
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
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherHits -Value $awayPitcherHits
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherIP -Value $awayPitcherIP
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherWHIP -Value $awayPitcherWHIP
	$obj | Add-Member -MemberType NoteProperty -Name AwayPitcherH9IP -Value $awayPitcherH9IP
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
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherHits -Value $homePitcherHits
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherIP -Value $homePitcherIP
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherWHIP -Value $homePitcherWHIP
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherH9IP -Value $homePitcherH9IP

	return $obj
}