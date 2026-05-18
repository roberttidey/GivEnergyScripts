## Thanks to TerraVolt for original examples
##Robert Tidey 2022

#####User details here#####
##Givenergy Portal API Key Goes Below between " "
 

$GivEnergyPortalAPI = "apikey"
$SerialNum = "serialno"
$DateFirst = Read-Host -Prompt "Enter start Date yyyy-MM-dd"
$DatePick = $DateFirst
$DateCount = Read-Host -Prompt "Enter number of days"
$page = 1
$pageSize = 1000
$DataPointsStr = "Date,Solar,Import,Export,Consumption,Battery`r`n"

########end user input#############

##Go Fetch Data Points##

$headers_Giv_En = @{
 'Authorization'="Bearer $GivEnergyPortalAPI"
 'Content-Type'='application/json'
 'Accept'='application/json'
 }

function GetDatePickData {
	$Giv_En =  Invoke-RestMethod -Method 'GET' -Uri https://api.givenergy.cloud/v1/inverter/$SerialNum/data-points/$DatePick"?"page=$page"&"pageSize=$pageSize -Headers $headers_Giv_En
	$Giv_Obj = $Giv_En | ConvertTo-Json -depth 10 | ConvertFrom-Json

	$last = $Giv_Obj.Data.Count - 1
	$solar = $Giv_Obj.Data[$last].today.solar
	$import = $Giv_Obj.Data[$last].today.grid.import
	$export = $Giv_Obj.Data[$last].today.grid.export
	$consumption = $Giv_Obj.Data[$last].today.consumption
	$battery = $Giv_Obj.Data[$last].power.battery.percent
	$parArray = @($DatePick,$solar,$import,$export,$consumption,$battery)
	$ret = $parArray -join ","
	return $ret + "`r`n"
}

for($index = 0; $index -lt $DateCount; $index++) {
	Write-Output $DatePick
	$DataPointsStr += GetDatePickData
	$DateObj = [Datetime]::ParseExact($DatePick, 'yyyy-MM-dd', $null)
	$DateObj = $DateObj.AddDays(1)
	$DatePick = $DateObj.ToString('yyyy-MM-dd')
}

$DataPointsStr | Out-File -FilePath .\DaysDataPoints_$DateFirst.txt
Write-Output "Data Saved to: DaysDataPoints_(Date).txt"
Write-Output "All done - Exit in 5...." 
start-sleep -s 5

Exit 