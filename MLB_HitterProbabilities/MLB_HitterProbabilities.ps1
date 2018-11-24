#
# Script.ps1
#

$a = Get-Date -format yyyyMMddhhmmss
$basePath = "C:\Users\pencez\source\repos\MLB_HitterProbabilities\MLB_HitterProbabilities"  #for LT
$logFile = "$($basePath)\Logs\MLB_HitterProbabilities_$($a).log"

# Location of external functions
. "$basePath\Functions\TheHitters.ps1"
. "$basePath\Functions\ThePitchers.ps1"
. "$basePath\Functions\TheMatchUps.ps1"
#. "$basePath\Functions\TheCalculation.ps1"
. "$basePath\Models\ApiFunctions.ps1"
. "$basePath\Models\HelperFunctions.ps1"





<#
# Set the API query parameters
$limit = "25"
$season = "2018"
$gameType = "R"

# Lookup top 20-30 hitters (by Average) and their preferences
$theHitters = GetTopAvgHitters $limit $season $gameType

# Save results to a json file
$jsonFile = "$($basePath)\Data\$($season)$($gameType).json"
$theHitters | ConvertTo-Json | Set-Content $jsonFile
#>

# Get players last 10-15 days of stats
#$theRecentStats = GetHittersRecentActivity $peopleId

# Check matchups for today
$season = "2018"
$gameType = "R"
$startDate = "03/29/$season".Replace("/","%2F")
$endDate = "03/30/$season".Replace("/","%2F")

$theGameInfo = GetGameInfo $gameType $startDate $endDate

	# get team
	# get location - home/away, dome/open, grass/turf
	# get date/time - day of week, day/night
	# get pitcher
		# throws left/right
		# pitchers ERA

# Calculate Probabilities
	# start with players average
	# +1 if playing at home
	# +.5 if dome/open preference
	# +.5 if grass/turf preference
	# +1 if day & time preferences align
		# +.5 if weekend/weekday preference
	# +1 if pitcher >= 4.00 ERA
	# +1 if pitcher hand is preferred
	# +1 if last X days < current average

# determine hot vs cold streaks


Exit