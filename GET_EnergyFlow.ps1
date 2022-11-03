#####User details here#####
##Givenergy Portal API Key Goes Below between " "
 

$GivEnergyPortalAPI = "apikey"
$SerialNum = "serialno"
$DateStart = Read-Host -Prompt "Enter Start Date yyyy-MM-dd"
$DateEnd = Read-Host -Prompt "Enter End Date yyyy-MM-dd"


########end user input#############

##Go Fetch Data Points##

$headers_Giv_En = @{
 'Authorization'="Bearer $GivEnergyPortalAPI"
 'Content-Type'='application/json'
 'Accept'='application/json'
 }
 
 $body = "{
    `"start_time`": `"$DateStart`",
    `"end_time`": `"$DateEnd`",
    `"grouping`": 0,
    `"types`": [0,1,2,3,4,5]
}"

$Giv_En =  Invoke-RestMethod -Method 'POST' -Uri https://api.givenergy.cloud/v1/inverter/$SerialNum/energy-flows"?" -Headers $headers_Giv_En -Body $body

$Giv_En | ConvertTo-Json -depth 10 | Out-File -FilePath .\EnergyFlows_$DatePick.txt

Write-Output "Data Saved to: EnergyFlows_(Date).txt"
Write-Output "All done - Exit in 5...." 
start-sleep -s 5

Exit 