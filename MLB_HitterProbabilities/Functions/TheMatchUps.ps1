#
# TheMatchups.ps1
#

Function getMatchupData($includeResultsYN) {
	#get thehitters from file
	$theHitters = Get-Content -Raw -Path "$($basePath)\Data\hittingLeaders_$($theDay.Replace('/','')).json" | Out-String | ConvertFrom-Json
	$theHittersDetails = Get-Content -Raw -Path "$($basePath)\Data\hittingLeaders_Details.json" | Out-String | ConvertFrom-Json
	$theGameInfo = Get-Content -Raw -Path "$($basePath)\Data\pregame_$($theDay.Replace('/','')).json" | Out-String | ConvertFrom-Json
	$theTeamFile = Get-Content -Raw -Path "$($basePath)\Data\teamInfo.json" | Out-String | ConvertFrom-Json
	
	LogWrite "Getting matchups_$($theDay.Replace('/','')) file started..."

	$theMatchupData = @()
	for ($h=0; $h -lt $theHitters.TopHitters.Count; $h++) {	
		$theTeam = $theHitters.TopHitters[$h].BatterTeamID
		$theTeamName = $theHitters.TopHitters[$h].BatterTeamName		
		$theTeamWins = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theTeam } | Select -ExpandProperty TeamWins 
		$theTeamLoss = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theTeam } | Select -ExpandProperty TeamLoss 
		$theLastGameWL = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theTeam } | Select -ExpandProperty LastGameWin 
		$theBatId = $theHitters.TopHitters[$h].BatterID
		$theBatName = $theHitters.TopHitters[$h].BatterName
		$batterSide = $theHitters.TopHitters[$h].BatterHittingSide
		$theBatAvg = $theHitters.TopHitters[$h].BatterCurrentAverage
		$theBatBabip = $theHitters.TopHitters[$h].BatterCurrentBABIP
		
		$theBatCarAvg = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterCareerAvg
		$theBatCarBabip = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterCareerBabip

		#$theBatCarAvg = $theHittersDetails.TopHitters[$h].BatterCareerAvg
		#$theBatCarBabip = $theHittersDetails.TopHitters[$h].BatterCareerBabip

					#TESTING
					if ($theBatName -eq "Buster Posey") {
						$stopHere = "STOP"
					}

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
			
			$theGameDate = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameDate
			$theGameMonth = $theGameDate.subString(5,2)
			if ($theGameMonth -eq "04") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgApr
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipApr
			} elseif ($theGameMonth -eq "05") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgMay
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipMay
			} elseif ($theGameMonth -eq "06") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgJun
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipJun
			} elseif ($theGameMonth -eq "07") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgJul
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipJul
			} elseif ($theGameMonth -eq "08") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgAug
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipAug
			} elseif ($theGameMonth -eq "09") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgSep
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipSep
			} elseif ($theGameMonth -eq "10") {
				$theBatAvgForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgOct
				$theBatBabipForMonth = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipOct
			}
			$theGameDayofWk = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameDayofWk
			if ($theGameDayofWk -eq "MON") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgMondays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipMondays 
			} elseif ($theGameDayofWk -eq "TUE") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgTuesdays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipTuesdays 
			}
			elseif ($theGameDayofWk -eq "WED") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgWednesdays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipWednesdays 
			}
			elseif ($theGameDayofWk -eq "THU") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgThursdays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipThursdays 
			}
			elseif ($theGameDayofWk -eq "FRI") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgFridays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipFridays 
			}
			elseif ($theGameDayofWk -eq "SAT") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgSaturdays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipSaturdays 
			}
			elseif ($theGameDayofWk -eq "SUN") { 
				$theBatAvgForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgSundays 
				$theBatBabipForDayofWk = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipSundays 
			}
			$theGameTime = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameTime
			$theGameAMPM = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameAMPM
			$theGameDayNight = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty GameDayNight			
			if ($theGameDayNight -eq "Day") { 
				$theBatAvgForDayNight = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgDay
				$theBatBabipForDayNight = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipDay 
			} else { 
				$theBatAvgForDayNight = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgNight
				$theBatBabipForDayNight = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipNight  
			}

			if ($homeAway -eq "Home") {
				# Get Batters AVG for when HOME
				$theBatAvgHomeAway = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgHome
				$theBatBabipHomeAway = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipHome				
				$theHitterAdv = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theTeam } | Select -ExpandProperty HitterAdv 
				$thePitcherAdv = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theTeam } | Select -ExpandProperty PitcherAdv 

				# get AWAY team/pitcher matchup data since hitter is at Home
				# "AwayTeamId":  "147", "AwayTeamName":  "New York Yankees", "AwayTeamWins":  "5", "AwayTeamLoss":  "6",
				$theVsTeamName = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayTeamName
				$theVsTeamWins = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayTeamWins
				$theVsTeamLoss = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayTeamLoss
				$theVsPitcherId = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherId
				$theVsPitcherName = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherName
				$theVsPitcherHand = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherHand
				$theVsPitcherWins = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherWins
				$theVsPitcherLoss = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherLoss
				$theVsPitcherEra = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty AwayPitcherEra
			} else {
				# Get Batters AVG for when AWAY
				$theBatAvgHomeAway = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgAway
				$theBatBabipHomeAway = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipAway
				
				# get HOME team/pitcher matchup data
				#"HomeTeamId":  "111", "HomeTeamName":  "Boston Red Sox", "HomeTeamWins":  "9", "HomeTeamLoss":  "1",			
				$theVsTeamId = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomeTeamId		
				$theHitterAdv = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theVsTeamId } | Select -ExpandProperty HitterAdv 
				$thePitcherAdv = $theTeamFile.TeamsData  | where { $_.TeamId -eq $theVsTeamId } | Select -ExpandProperty PitcherAdv				
				$theVsTeamName = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomeTeamName
				$theVsTeamWins = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomeTeamWins
				$theVsTeamLoss = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomeTeamLoss				
				$theVsPitcherId = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherId
				$theVsPitcherName = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherName
				$theVsPitcherHand = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherHand
				$theVsPitcherWins = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherWins
				$theVsPitcherLoss = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherLoss
				$theVsPitcherEra = $theGameInfo.GameInfo | where { $_.GamePk -eq $theGamePk } | Select -ExpandProperty HomePitcherEra
			}			
			if ($theVsPitcherHand -eq "R") { 
				$theBatAvgVsHand = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgToRighty
				$theBatBabipVsHand = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipToRighty
			} else { 
				$theBatAvgVsHand = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgToLefty
				$theBatBabipVsHand = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipToLefty
			}			
			$theBatAvgTeamWins = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgTeamWins
			$theBatBabipTeamWins = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipTeamWins
			$theBatAvgTeamLoss = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgTeamLoss
			$theBatBabipTeamLoss = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipTeamLoss
			$theBatAvgAfterW = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgTeamAfterW
			$theBatBabipAfterW = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipTeamAfterW
			$theBatAvgAfterL = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterAvgTeamAfterL
			$theBatBabipAfterL = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty BatterBabipTeamAfterL
			$theBatAvg1stHalf = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty batterAvgPreAllStar
			$theBatBabip1stHalf = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty batterBabipPreAllStar
			$theBatAvg2ndHalf = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty batterAvgPostAllStar
			$theBatBabip2ndHalf = $theHittersDetails.TopHitterDetails | where { $_.BatterID -eq $theBatId } | Select -ExpandProperty batterBabipPostAllStar
						
			if ($includeResultsYN -eq "Yes") {
				# get results too
				$theUri = "https://statsapi.mlb.com/api/v1/people/$($theBatId)/stats/game/$($theGamePk)?group=hitting"
				$theFields = "stats"
				$getResultsData = GetApiData $theUri $theFields
				if ($getResultsData) {
					$resultHits = $getResultsData[0].splits[0].stat.hits
					$resultAtBats = $getResultsData[0].splits[0].stat.atbats
				} else {
					$resultHits = "?"
					$resultAtBats = "?"
				}
			}

			$theMatchupData += BuildMatchupsData
			# clear the variables for the next run in loop
			$versusArray = ("theVsTeamName","theVsTeamWins","theVsTeamLoss","theVsPitcherId", "theVsPitcherName", "theVsPitcherHand", "theVsPitcherWins", "theVsPitcherLoss", "theVsPitcherEra")
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
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabip -Value $theBatBabip
	$obj | Add-Member -MemberType NoteProperty -Name BattingSide -Value $batterSide
	$obj | Add-Member -MemberType NoteProperty -Name CareerAvg -Value $theBatCarAvg
	$obj | Add-Member -MemberType NoteProperty -Name CareerBabip -Value $theBatCarBabip
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeamId -Value $theTeam
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeam -Value $theTeamName	
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeamWins -Value $theTeamWins
	$obj | Add-Member -MemberType NoteProperty -Name BatterTeamLoss -Value $theTeamLoss
	$obj | Add-Member -MemberType NoteProperty -Name BatterLastGameWL -Value $theLastGameWL
	$obj | Add-Member -MemberType NoteProperty -Name HomeOrAway -Value $homeAway
	$obj | Add-Member -MemberType NoteProperty -Name GamePk -Value $theGamePk
	$obj | Add-Member -MemberType NoteProperty -Name GameDate -Value $theDay
	$obj | Add-Member -MemberType NoteProperty -Name GameTime -Value $theGameTime
	$obj | Add-Member -MemberType NoteProperty -Name GameAMPM -Value $theGameAMPM
	$obj | Add-Member -MemberType NoteProperty -Name GameDayofWk -Value $theGameDayofWk
	$obj | Add-Member -MemberType NoteProperty -Name GameDayNight -Value $theGameDayNight
	#$obj | Add-Member -MemberType NoteProperty -Name GameTimeZone -Value $theGameTimeZone
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherTeam -Value $theVsTeamName
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherTeamWins -Value $theVsTeamWins
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherTeamLoss -Value $theVsTeamLoss
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherId -Value $theVsPitcherId
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherName -Value $theVsPitcherName
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherHand -Value $theVsPitcherHand
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherWins -Value $theVsPitcherWins
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherLoss -Value $theVsPitcherLoss
	$obj | Add-Member -MemberType NoteProperty -Name OppPitcherEra -Value $theVsPitcherEra
	$obj | Add-Member -MemberType NoteProperty -Name BatterStadiumAdv -Value $theHitterAdv 
	$obj | Add-Member -MemberType NoteProperty -Name PitcherStadiumAdv -Value $thePitcherAdv
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgHomeAway -Value $theBatAvgHomeAway
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipHomeAway -Value $theBatBabipHomeAway
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgForMonth -Value $theBatAvgForMonth
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipForMonth -Value $theBatBabipForMonth
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgForDayofWk -Value $theBatAvgForDayofWk
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipForDayofWk -Value $theBatBabipForDayofWk
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgForDayNight -Value $theBatAvgForDayNight
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipForDayNight -Value $theBatBabipForDayNight
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgVsHand -Value $theBatAvgVsHand
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipVsHand -Value $theBatBabipVsHand
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgIfTeamWins -Value $theBatAvgTeamWins
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipIfTeamWins -Value $theBatBabipTeamWins
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgIfTeamLoss -Value $theBatAvgTeamLoss
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipIfTeamLoss -Value $theBatBabipTeamLoss
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgAfterTeamWins -Value $theBatAvgAfterW
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipAfterTeamWins -Value $theBatBabipAfterW
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvgAfterTeamLoss -Value $theBatAvgAfterL
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabipAfterTeamLoss -Value $theBatBabipAfterL
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvg1stHalfSeason -Value $theBatAvg1stHalf
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabip1stHalfSeason -Value $theBatBabip1stHalf
	$obj | Add-Member -MemberType NoteProperty -Name BatterAvg2ndHalfSeason -Value $theBatAvg2ndHalf
	$obj | Add-Member -MemberType NoteProperty -Name BatterBabip2ndHalfSeason -Value $theBatBabip2ndHalf


	# get hit probability
	#$hitProb = BuildHitProbabilityNumber
	#$obj | Add-Member -MemberType NoteProperty -Name HitProbability -Value $hitProb
	$hitAdvCntr = advantageCounter
	$obj | Add-Member -MemberType NoteProperty -Name HitAdvantage -Value $hitAdvCntr
	
	$statsLast1D = getRecentAvg 1
	$obj | Add-Member -MemberType NoteProperty -Name AVGYesterday -Value $statsLast1D[0]
	$obj | Add-Member -MemberType NoteProperty -Name BABIPYesterday -Value $statsLast1D[1].toString(".###")
	$statsLast3D = getRecentAvg 3
	$obj | Add-Member -MemberType NoteProperty -Name AVG3Days -Value $statsLast3D[0]
	$obj | Add-Member -MemberType NoteProperty -Name BABIP3Days -Value $statsLast3D[1].toString(".###")
	$statsLast5D = getRecentAvg 5
	$obj | Add-Member -MemberType NoteProperty -Name AVG5Days -Value $statsLast5D[0]
	$obj | Add-Member -MemberType NoteProperty -Name BABIP5Days -Value $statsLast5D[1].toString(".###")
	$statsLast7D = getRecentAvg 7
	$obj | Add-Member -MemberType NoteProperty -Name AVG7Days -Value $statsLast7D[0]
	$obj | Add-Member -MemberType NoteProperty -Name BABIP7Days -Value $statsLast7D[1].toString(".###")
	$statsLast10D = getRecentAvg 10
	$obj | Add-Member -MemberType NoteProperty -Name AVG10Days -Value $statsLast10D[0]
	$obj | Add-Member -MemberType NoteProperty -Name BABIP10Days -Value $statsLast10D[1].toString(".###")
	$statsLast14D = getRecentAvg 14
	$obj | Add-Member -MemberType NoteProperty -Name AVG14Days -Value $statsLast14D[0]
	$obj | Add-Member -MemberType NoteProperty -Name BABIP14Days -Value $statsLast14D[1].toString(".###")

	if ($includeResultsYN -eq "Yes") {
		$obj | Add-Member -MemberType NoteProperty -Name BatterResultAtBats -Value $resultAtBats
		$obj | Add-Member -MemberType NoteProperty -Name BatterResultHits -Value $resultHits
	}

	return $obj
}