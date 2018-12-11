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
	#$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&startDate=$($startDate)&endDate=$($endDate)"
	$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&date=$($date)"	
	$theFields = "dates"
	$getGameData = GetApiData $theUri $theFields

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

		$theGameInfo = @()
		$theRootObj = New-Object -TypeName psobject
		$theRootObj| Add-Member -MemberType NoteProperty -Name GameInfo -Value $theGameData
		$theGameInfo += $theRootObj

		WriteToJsonFile $basePath "pregame_$($theDay.Replace('/',''))" $theGameInfo
		LogWrite "File pregame_$($theDay.Replace('/','')) was created!"
	}
}

function GetGameResults($gameType, $date) {
	#$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&startDate=$($startDate)&endDate=$($endDate)"
	$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&date=$($date)"	
	$theFields = "dates"
	$getGameData = GetApiData $theUri $theFields

	$theGameData = @()
	foreach($date in $getGameData) {
		$gameDate = $date.date
		$dateStamp = $gameDate.replace('-','')
		foreach($game in $date.games) {
			$gamePk = $game.gamePk
			$feedUri = "https://statsapi.mlb.com/api/v1/game/$($gamePk)/feed/live?timecode=$($dateStamp)_235500"
			$gameDetails = GetGameDetails $feedUri
			$theGameData += $gameDetails
		}
		
		$theGameResults = @()
		$theRootObj = New-Object -TypeName psobject
		$theRootObj| Add-Member -MemberType NoteProperty -Name GameResults -Value $theGameData
		$theGameResults += $theRootObj

		WriteToJsonFile $basePath "postgame_$($theDay.Replace('/',''))" $theGameResults
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
		
	$gameDayofWk = $getGameData.datetime.day
	$gameTime = $getGameData.datetime.home.time
	$gameAmPm = $getGameData.datetime.home.ampm
	$gameDayNight = $getGameData.datetime.dayNight
	$gameTimeZone = $getGameData.datetime.home.timeZone
	$weatherCond = $getGameData.weather.condition
	$weatherTemp = $getGameData.weather.temp
	$weatherWind = $getGameData.weather.wind
	$venueCity = $getGameData.venue.location
	$venueSite = $getGameData.venue.name
	
	#away team details
	$awayTeamId = $getGameData.teams.away.teamID
	$awayTeam = $getGameData.teams.away.name.full
	$awayTeamW = $getGameData.teams.away.record.wins
	$awayTeamL = $getGameData.teams.away.record.losses	
	$awayPitcherId = $getLiveData.boxscore.teams.away.pitchers[0]
	$awayPlayerPath = $getLiveData.boxscore.teams.away.players
	$awayPlayerIDnId = "ID" + $awayPitcherId
	$awayPlayerById = $awayPlayerPath.$awayPlayerIDnId
	$awayPitcherName = $awayPlayerById.name.first + " " + $awayPlayerById.name.last
	$awayPitcherRightLeft = $awayPlayerById.rightLeft
	$awayPitcherWins = $awayPlayerById.seasonStats.pitching.wins
	$awayPitcherWins = $awayPlayerById.seasonStats.pitching.losses
	$awayPitcherEra = $awayPlayerById.seasonStats.pitching.era
	
	#home team details
	$homeTeamId = $getGameData.teams.home.teamID
	$homeTeam = $getGameData.teams.home.name.full
	$homeTeamW = $getGameData.teams.home.record.wins
	$homeTeamL = $getGameData.teams.home.record.losses
	$homePitcherId = $getLiveData.boxscore.teams.home.pitchers[0]
	$homePlayerPath = $getLiveData.boxscore.teams.home.players
	$homePlayerIDnId = "ID" + $homePitcherId
	$homePlayerById = $homePlayerPath.$homePlayerIDnId
	$homePitcherName = $homePlayerById.name.first + " " + $homePlayerById.name.last
	$homePitcherRightLeft = $homePlayerById.rightLeft
	$homePitcherWins = $homePlayerById.seasonStats.pitching.wins
	$homePitcherLoss = $homePlayerById.seasonStats.pitching.losses
	$homePitcherEra = $homePlayerById.seasonStats.pitching.era
	
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
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherId -Value $homePitcherId
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherName -Value $homePitcherName
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherHand -Value $homePitcherRightLeft
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherWins -Value $homePitcherWins
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherLoss -Value $homePitcherLoss
	$obj | Add-Member -MemberType NoteProperty -Name HomePitcherEra -Value $homePitcherEra

	return $obj
}