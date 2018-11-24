#
# TheMatchUps.ps1
#

function GetGameInfo($gameType, $startDate, $endDate) {
	$theUri = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&gameType=$($gameType)&startDate=$($startDate)&endDate=$($endDate)"	
	$theFields = "dates"
	$getGameData = GetApiData $theUri $theFields

	foreach($date in $getGameData) {
		$gameDate = $date.date
		$dateStamp = $gameDate.replace('-','')
		foreach($game in $date.games) {
			$gamePk = $game.gamePk
			$feedUri = "https://statsapi.mlb.com/api/v1/game/$($gamePk)/feed/live?timecode=$($dateStamp)_010000"
			$gameDetails = GetGameDetails $feedUri

		}
	}
	$gameIds = $getGameData.games.gamePk

}

function GetGameDetails($feedUri) {	
	$theFields = "gameData"
	$getGameData = GetApiData $feedUri $theFields
		
	$gameDayofWk = $getGameData.datetime.day
	$gameTime = $getGameData.datetime.time
	$gameDayNight = $getGameData.datetime.dayNight
	$gameTimeZone = $getGameData.datetime.timeZone
	$weatherCond = $getGameData.weather.condition
	$weatherTemp = $getGameData.weather.temp
	$weatherWind = $getGameData.weather.wind
	$venueCity = $getGameData.venue.location
	$venueSite = $getGameData.venue.name
	$awayTeam = $getGameData.teams.away.name.full
	$awayTeamW = $getGameData.teams.away.record.wins
	$awayTeamL = $getGameData.teams.away.record.losses	
	$homeTeam = $getGameData.teams.home.name.full
	$homeTeamW = $getGameData.teams.home.record.wins
	$homeTeamL = $getGameData.teams.home.record.losses

	#get probables; re-run API
	$theFields = "liveData"
	$getLiveData = GetApiData $feedUri $theFields
	
	$awayPitcherId = $getLiveData.boxscore.teams.away.pitchers[0]
	$awayPlayerPath = $getLiveData.boxscore.teams.away.players
	$awayPlayerIDnId = "ID" + $awayPitcherId
	$awayPlayerById = $awayPlayerPath.$awayPlayerIDnId
	$awayPitcherName = $awayPlayerById.name.first + " " + $awayPlayerById.name.last
	$awayPitcherRightLeft = $awayPlayerById.rightLeft
	$awayPitcherWins = $awayPlayerById.seasonStats.pitching.wins
	$awayPitcherWins = $awayPlayerById.seasonStats.pitching.losses
	$awayPitcherEra = $awayPlayerById.seasonStats.pitching.era
		
	$homePitcherId = $getLiveData.boxscore.teams.home.pitchers[0]
	$homePlayerPath = $getLiveData.boxscore.teams.home.players
	$homePlayerIDnId = "ID" + $homePitcherId
	$homePlayerById = $homePlayerPath.$homePlayerIDnId
	$homePitcherName = $homePlayerById.name.first + " " + $homePlayerById.name.last
	$homePitcherRightLeft = $homePlayerById.rightLeft
	$homePitcherWins = $homePlayerById.seasonStats.pitching.wins
	$homePitcherWins = $homePlayerById.seasonStats.pitching.losses
	$homePitcherEra = $homePlayerById.seasonStats.pitching.era
	
	$test = "Got it!"
}