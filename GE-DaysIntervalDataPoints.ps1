## Thanks to TerraVolt for original examples
##Robert Tidey 2022

#####User details here#####
##Givenergy Portal API Key Goes Below between " "

## if $Cumulative is 1 then values reported are cumulative, if 0 then energy differences are used.
$Cumulative = 0

$GivEnergyPortalAPI = "apikey"
$SerialNum = "serialno"
$DateFirst = Read-Host -Prompt "Enter start Date yyyy-MM-dd"
$DatePick = $DateFirst
$DateCount = Read-Host -Prompt "Enter number of days"
$page = 1
$pageSize = 1000
$DataPointsStr = "Date,Period,Time,Solar,Import,Export,Consumption,Battery"
## If PeriodInterval is 0 then IntervalTimes are used else it sets a regular interval throughout the day e.g. 30 minutes
$PeriodInterval = 0
## Intervaltimes array if PeriodInterval is 0.  Times in minutes in minutes
## default is for Flux periods
$IntervalTimes = @(120,300,960,1140,1440)
$GMTOffset = 0

########end user input#############

##Go Fetch Data Points##

$headers_Giv_En = @{
 'Authorization'="Bearer $GivEnergyPortalAPI"
 'Content-Type'='application/json'
 'Accept'='application/json'
 }

 
function justMinutes([String]$tmpTime) {
	$minutes = [Decimal]$tmpTime.Substring(11,2) * 60 + [Decimal]$tmpTime.Substring(14,2) + $GMTOffset
	if($minutes -gt 1439) {
		$minutes = $minutes - 1440
	}
	return [int]$minutes
}

function formatMinutes($tmpMinutes) {
	$t = ([int]$tmpMinutes) / 60
	$t = [Math]::Floor($t)
	$t = [int]$t
	$h = [String]($t)
	if ($h.Length -eq 1) {
		$h = "0" + $h
	}
	$t = [int][Math]::Floor($tmpMinutes % 60)
	$m = [String]$t
	if ($m.Length -eq 1) {
		$m = "0" + $m
	}
	return $h + ":" + $m 
}

function WriteDateFluxData {
	$GMTOffset = 0	
	$Giv_En =  Invoke-RestMethod -Method 'GET' -Uri https://api.givenergy.cloud/v1/inverter/$SerialNum/data-points/$DatePick"?"page=$page"&"pageSize=$pageSize -Headers $headers_Giv_En
	$Giv_Obj = $Giv_En | ConvertTo-Json -depth 10 | ConvertFrom-Json

	$last = $Giv_Obj.Data.Count
	$recminutes = justMinutes($Giv_Obj.Data[0].time)
	if($recminutes -gt 10) {
		$GMTOffset = 60
	}
	$period = 0
	$nextPeriod = $PeriodInterval
	$solarlast = 0
	$importlast = 0
	$exportlast = 0
	$consumptionlast = 0
	$parArray = 0," ",0,0,0,0,0
	$nextPeriod = $IntervalTimes[$period]
	for($rec = 0; $rec -lt $last; $rec++) {
		$recminutes = justMinutes($Giv_Obj.Data[$rec].time)
		if($PeriodInterval -eq 0) {
			$nextPeriod = $IntervalTimes[$period]
		}
		if((($recminutes -gt $nextPeriod) -and ($nextPeriod -lt 1440)) -or ($rec -eq ($last -1))) {
			if($PeriodInterval -gt 0) {
				$nextPeriod = $nextPeriod + $PeriodInterval
			}
			$parArray[0] = $period
			$parArray[1] = formatMinutes($recminutes)
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.solar
			$parArray[2] = $temp - $solarlast
			if ($Cumulative -eq 0) {$solarlast = $temp}
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.grid.import
			$parArray[3] = $temp - $importlast
			if ($Cumulative -eq 0) {$importlast = $temp}
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.grid.export
			$parArray[4] = $temp - $exportlast
			if ($Cumulative -eq 0) {$exportlast = $temp}
			$temp = [Decimal]$Giv_Obj.Data[$rec].today.consumption
			$parArray[5] = $temp - $consumptionlast
			if ($Cumulative -eq 0) {$consumptionlast = $temp}
			$parArray[6] = [Decimal]$Giv_Obj.Data[$rec].power.battery.percent 
			$DataPointsStr = $DatePick + "," + ($parArray -join ",")
			Add-Content .\IntervalDataPoints_$DateFirst.txt $DataPointsStr
			$period = $period + 1
		}
	}
}

$DataPointsStr | Out-File -FilePath .\IntervalDataPoints_$DateFirst.txt

for($index = 0; $index -lt $DateCount; $index++) {
	Write-Output $DatePick
	WriteDateFluxData
	$DateObj = [Datetime]::ParseExact($DatePick, 'yyyy-MM-dd', $null)
	$DateObj = $DateObj.AddDays(1)
	$DatePick = $DateObj.ToString('yyyy-MM-dd')
}


Write-Output "Data Saved to: IntervalDataPoints_(Date).txt"
Write-Output "All done - Exit in 5...." 
start-sleep -s 45

Exit 