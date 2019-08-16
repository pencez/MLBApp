#
# MLB_HitterProbabilities.ps1
#

#clear all vars to start
#Get-UserVariable | Clear-Variable


$testing = 0
$justGetResultsData = 0



$a = Get-Date -format yyyyMMddhhmmss
$basePath = "C:\Users\pencez\source\repos\MLBApp\MLB_HitterProbabilities"     #for LT
$webPath = "C:\Users\pencez\source\repos\MLBApp\MLB_HitterProbabilities_Web"  #for LT
$logFile = "$($basePath)\Logs\MLB_HitterProbabilities_$($a).log"

# Location of external functions
. "$basePath\Functions\TheHitters.ps1"
. "$basePath\Functions\ThePitchers.ps1"
. "$basePath\Functions\TheGames.ps1"
. "$basePath\Functions\TheMatchups.ps1"
. "$basePath\Functions\TheResults.ps1"
. "$basePath\Functions\TheCalculations.ps1"
. "$basePath\Models\ApiFunctions.ps1"
. "$basePath\Models\FileFunctions.ps1"
. "$basePath\Models\HelperFunctions.ps1"


<#
Write-Host $testDtM1

Start-Sleep -Seconds 5
Exit
#>


if ($justGetResultsData -eq 1) {
	LogWrite "Going down result data path..."
	getResultsData

	LogWrite "Completed getting just the result data"

} else {



	if ($testing -eq 0) {
	
		# Set the API query parameters
		$limit = "25"
		$season = "2019"
		$gameType = "R"
		$theDay = Get-Date -format MM/dd/yyyy
		#$theDay = "08/04/2019"

		#<#
		# Get top hitters by avg in MLB
		$theHitters = GetTopAvgHitters $limit $season $gameType

		# Get results for previous day
		$theGameResults = updateTeamRecords $gameType $theDay
		# Get information for today
		$theGameInfo = GetGameInfo $gameType $theDay.Replace("/","%2F")
		#>

		$theMatchups = getMatchupData "No"

		# Copy the matchups file to the webapp
		Copy-Item "$($basePath)\Data\matchups_$($theDay.Replace('/','')).json" -Destination "$($webPath)\AppData\"
		LogWrite "Matchup file copied to web app"

	} else {
		# TESTING MODE
		$logFile = "$($basePath)\Logs\MLB_HitterProbabilities_TEST_$($a).log"
		$theDate = Get-Date "05/01/2018"

		while ($testDate -ne "05/30/2018") {	
			$testDate = $theDate.ToString("MM/dd/yyyy")
			$testDtM1 = $theDate.AddDays(-1).ToString("MM/dd/yyyy")


			# Set the API query parameters
			# ****************************************************************************************************
			# Use this for testing to get best average during date range(s)			
			$season = "2018"
			$gameType = "R"
			$seasonStartDate = "03/29/$season".Replace("/","%2F")
			$seasonCurrDate = $testDtM1.Replace("/","%2F")
			$theDay = $testDate
			$lastSeason = "2017"
			$currSeason = "2018"	
			$limit = "20"	

			#<# 
			$theHitters = GetTopAvgHittersTesting $limit $lastSeason $gameType $seasonStartDate $seasonCurrDate
			# ****************************************************************************************************
			#>
			<#
			# Check matchups for today
			###$theGameInfo = GetGameInfo $gameType $startDate $endDate
			$theGameInfo = GetGameInfo $gameType $theDay.Replace("/","%2F")

				# Get results for *testing* days
				$theGameResults = GetGameResults $gameType $theDay.Replace("/","%2F")
			#>


			#<#
	
			# Build results
			# getMatchupData($includeResultsYN Yes/No) -- typically this is "no" for actual use but yes during testing
			$theMatchups = getMatchupData "Yes"

			# Copy the matchups file to the webapp
			Copy-Item "$($basePath)\Data\Test\matchups_$($theDay.Replace('/','')).json" -Destination "$($webPath)\AppData\"
			LogWrite "Matchup file copied to web app"
			#>


			$theDate = $theDate.AddDays(1)
		}
	}


}

#Get list of hit leaders and team id
##$theTopHitters = GetHitterList
#Get info from postgame for each hitter and get gamepk
#Query each game specifically https://statsapi.mlb.com/api/v1/people/<batterid>/stats/game/<gamepk>


# Get players last 10-15 days of stats
#$theRecentStats = GetHittersRecentActivity $peopleId


# Calculate Probabilities
	# start with players average or 30 out of 100
	# +1 if playing at home
	# +.5 if dome/open preference
	# +.5 if grass/turf preference
	# +1 if day & time preferences align
		# +.5 if weekend/weekday preference
	# +1 if pitcher >= 4.00 ERA
	# +1 if pitcher hand is preferred
	# +1 if last X days < current average


#Look at ballpark factor
	#Home team stats at home vs away - Giants got 1200 hits at home and 990 away, ballpark factor is 1.212


# determine hot vs cold streaks

LogWrite "********** COMPLETED SUCCESSFULLY **********"
Start-Sleep -s 2

# This will clear all variables used in script
Get-UserVariable | Clear-Variable
Exit