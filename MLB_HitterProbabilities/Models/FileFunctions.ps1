#
# FileFunctions.ps1
#

function WriteToJsonFile($basePath, $fileName, $theData) {
	# Save results to a json file
	$jsonFile = "$($basePath)\Data\$($fileName).json"
	$theData | ConvertTo-Json | Set-Content $jsonFile

	return "success"
}