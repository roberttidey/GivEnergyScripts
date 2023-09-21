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
$DataPointsStr = "Date,Sol1,Imp1,Exp1,Con1,Bat1,Sol2,Imp2,Exp2,Con2,Bat2,Sol3,Imp3,Exp3,Con3,Bat3,Sol4,Imp4,Exp4,Con4,Bat4,Sol5,Imp5,Exp5,Con5,Bat5"

########end user input#############

##Go Fetch Data Points##

$headers_Giv_En = @{
 'Authorization'="Bearer $GivEnergyPortalAPI"
 'Content-Type'='application/json'
 'Accept'='application/json'
 }

 
function justHour($recTime) {
	 return [Decimal]$recTime.Substring(11,2)
}


function WriteDateFluxData {
	$Giv_En =  Invoke-RestMethod -Method 'GET' -Uri https://api.givenergy.cloud/v1/inverter/$SerialNum/data-points/$DatePick"?"page=$page"&"pageSize=$pageSize -Headers $headers_Giv_En
	$Giv_Obj = $Giv_En | ConvertTo-Json -depth 10 | ConvertFrom-Json

	$last = $Giv_Obj.Data.Count
	if(justHour($Giv_Obj.Data[0].time) -eq 0) {
		$FluxTimes = @(2,5,16,19,24)
	} else {
		$FluxTimes = @(1,4,15,18,24)
	}
	$period = 0
	$solarlast = 0
	$importlast = 0
	$exportlast = 0
	$consumptionlast = 0
	$DataPointsStr = $DataPick
	for($rec = 0; $rec -lt $last; $rec++) {
		$rectime = justHour($Giv_Obj.Data[$rec].time)
		if(($recTime -eq $FluxTimes[$period]) -or ($rec -eq ($last -1))) {
			$parArray = 0,0,0,0,0
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.solar
			$parArray[0] = $temp - $solarlast
			$solarlast = $temp
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.import
			$parArray[1] = $temp - $importlast
			$importlast = $temp
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.export
			$parArray[2] = $temp - $exportlast
			$exportlast = $temp
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.consumption
			$parArray[3] = $temp - $consumptionlast
			$consumptionlast = $temp
			$parArray[4] = [Decimal]$Giv_Obj.Data[$rec].power.battery.percent 
			$DataPointsStr = $DataPointsStr + "," + ($parArray -join ",")
			$period = $period + 1
		}
	}
	Add-Content .\FluxDataPoints_$DateFirst.txt $DataPointsStr
}


$DataPointsStr | Out-File -FilePath .\FluxDataPoints_$DateFirst.txt

for($index = 0; $index -lt $DateCount; $index++) {
	Write-Output $DatePick
	WriteDateFluxData
	$DateObj = [Datetime]::ParseExact($DatePick, 'yyyy-MM-dd', $null)
	$DateObj = $DateObj.AddDays(1)
	$DatePick = $DateObj.ToString('yyyy-MM-dd')
}


Write-Output "Data Saved to: FluxDataPoints_(Date).txt"
Write-Output "All done - Exit in 5...." 
start-sleep -s 5

Exit 