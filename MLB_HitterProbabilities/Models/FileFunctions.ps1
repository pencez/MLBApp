#
# FileFunctions.ps1
#

function WriteToJsonFile($filePath, $fileName, $theData) {
	# Save results to a json file

	$jsonFile = "$($filePath)\$($fileName).json"
	$theData | ConvertTo-Json | Set-Content $jsonFile

	return "success"
}