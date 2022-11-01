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
$pageSize = 300
$DataPointsStr = "Date,Solar,Import,Export,Consumption,Battery`r`n"

########end user input#############

##Go Fetch Data Points##

$headers_Giv_En = @{
 'Authorization'="Bearer $GivEnergyPortalAPI"
 'Content-Type'='application/json'
 'Accept'='application/json'
 }

function WriteDateFullPickData {
	$Giv_En =  Invoke-RestMethod -Method 'GET' -Uri https://api.givenergy.cloud/v1/inverter/$SerialNum/data-points/$DatePick"?"page=$page"&"pageSize=$pageSize -Headers $headers_Giv_En
	$Giv_Obj = $Giv_En | ConvertTo-Json -depth 10 | ConvertFrom-Json

	$last = $Giv_Obj.Data.Count - 1
	for($rec = 0; $rec -lt $last; $rec++) {
		$rectime = $Giv_Obj.Data[$rec].time
		$solar = $Giv_Obj.Data[$rec].today.solar
		$import = $Giv_Obj.Data[$rec].today.grid.import
		$export = $Giv_Obj.Data[$rec].today.grid.export
		$consumption = $Giv_Obj.Data[$rec].today.consumption
		$battery = $Giv_Obj.Data[$rec].power.battery.percent
		$parArray = @($rectime,$solar,$import,$export,$consumption,$battery)
		$DataPointsStr = $parArray -join ","
		Add-Content .\FullDataPoints_$DateFirst.txt $DataPointsStr
	}
}

$DataPointsStr | Out-File -FilePath .\FullDataPoints_$DateFirst.txt

for($index = 0; $index -lt $DateCount; $index++) {
	Write-Output $DatePick
	WriteDateFullPickData
	$DateObj = [Datetime]::ParseExact($DatePick, 'yyyy-MM-dd', $null)
	$DateObj = $DateObj.AddDays(1)
	$DatePick = $DateObj.ToString('yyyy-MM-dd')
}

Write-Output "Data Saved to: DataPoints_(Date).txt"
Write-Output "All done - Exit in 5...." 
start-sleep -s 5

Exit 