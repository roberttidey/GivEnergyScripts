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
$DataPointsStr = "Date,Solar Today,Solar Total,Import Today,Import Total,Export Today,Export Total,Consumption Today,Consumption Total,Charge Today,Discharge Today,Battery SoC %"

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

	$last = $Giv_Obj.Data.Count
	for($rec = 0; $rec -lt $last; $rec++) {
        # GivEnergy portal holds all data with date/times in UTC, so in summertime a 'day' starts and ends at 23:00 UTC
        # Extract date/time from GivEnergy data and convert to datetime object which automatically converts to local time (and adjusts for summertime offset)
        $rectime = [datetime]::Parse($Giv_Obj.Data[$rec].time)

        # extract other inverter data items we are interested in
		$solarToday = $Giv_Obj.Data[$rec].today.solar
		$importToday = $Giv_Obj.Data[$rec].today.grid.import
		$exportToday = $Giv_Obj.Data[$rec].today.grid.export
		$consumptionToday = $Giv_Obj.Data[$rec].today.consumption
        $chargeToday = $Giv_Obj.Data[$rec].today.battery.charge
        $dischargeToday = $Giv_Obj.Data[$rec].today.battery.discharge
		$batterySoC = $Giv_Obj.Data[$rec].power.battery.percent
		$solarTotal = $Giv_Obj.Data[$rec].total.solar
		$importTotal = $Giv_Obj.Data[$rec].total.grid.import
		$exportTotal = $Giv_Obj.Data[$rec].total.grid.export
		$consumptionTotal = $Giv_Obj.Data[$rec].total.consumption

		# add the data to the output array
		$parArray = @($rectime,$solarToday,$solarTotal,$importToday,$importTotal,$exportToday,$exportTotal,$consumptionToday,$consumptionTotal,$chargeToday,$dischargeToday,$batterySoC)
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

Write-Output "Data Saved to: FullDataPoints_$DateFirst.txt"
Write-Output "All done - Exit in 5...." 
start-sleep -s 5

Exit 