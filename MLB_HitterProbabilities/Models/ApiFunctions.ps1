#
# ApiFunctions.ps1
#

function GetApiData($theUri, $theFields) {
	# Set the headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    #$headers.Add("Authorization", $($bearer))
    $headers.Add("Content-Type", "application/json")
    
	try {
		# Run the REST call
		$response = Invoke-RestMethod -uri "$($theUri)" -Method GET -Headers $headers 
	   
		if ($response.hasError -eq "true")  
		{
			LogWrite 'Theres an Error!'
			LogWrite "'Status Message :' $($response.error)"
			$retMsg = "'Error: ' $($response.error)"
		}
		else
		{
			#LogWrite "Successful!"
			$retMsg = $($response.$($theFields))
		} 

	} catch {
		$ErrorMessage = $_.Exception.Message
	}

    return $retMsg

}