#####User details here#####
##Givenergy Portal API Key Goes Below between " "
 

$GivEnergyPortalAPI = "apikey"
$SerialNum = "serialno"

########end user input#############

##Go Fetch Data Points##

$headers_Giv_En = @{
 'Authorization'="Bearer $GivEnergyPortalAPI"
 'Content-Type'='application/json'
 'Accept'='application/json'
 }

$Giv_En =  Invoke-RestMethod -Method 'GET' -Uri https://api.givenergy.cloud/v1/inverter/$SerialNum/system-data/latest -Headers $headers_Giv_En

$Giv_En | ConvertTo-Json -depth 10 | Out-File -FilePath .\LatestSystemData.json

Write-Output "Data Saved to: LatestSystemData.json"
Write-Output "All done - Exit in 5...." 
start-sleep -s 5

Exit 