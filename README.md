# GivEnergy API powershell scripts

Note that you may have to enable running powershell scripts. Search for a guide on how to do this.

## GE-DaysDataPoints.ps1
- Script to extract daily summary for a range of dates to a csv file
- edit to put in apikey and GivEnergy serial number
- Save and run in powershell with right click
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields for date,solar,import, export,consumption and final battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extractign full data for each day, parsing into data object and looking for last entry which contains today totals

## GE-DaysFullDataPoints.ps1
- Script to extract data at 5 mminute intervals for a range of dates to a csv file
- edit to put in apikey and GivEnergy serial number
- Save and run in powershell with right click
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields for time,solar,import, export,consumption and battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extracting full data for each day, parsing into data object and iterating over all records

## GE-DaysIntervalDataPoints.ps1
- Script to extract data over periods per day for a range of dates to a csv file
- edit to put in apikey and GivEnergy serial number
- Save and run in powershell with right click
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields date, periodindex,time,solar,import, export,consumption and battery percentage
- Energy values are kwH. If $Cumulative variable in script is set to 1 then values are running total. If 0 then they are the value in that period.
- Periods can be regular times set by $periodInterval in minutes
- If $periodInterval is set to 0 then an array of fixed times in minutes is used ($IntervalTimes)
- The default $IntervalTimes is for Octopus Flux 
- Works by extracting full data for each day, parsing into data object and iterating over all records looking for the period data

## GE-EnergyFlow.ps1
- Script to extract energyflow data
- edit to put in apikey and GivEnergy serial number
- edit to change grouping required Default 0 = 30 minutes
- edit to change id types required Default 0,1,2,3,4,5
- Save and run in powershell with right click
- enter start date in yyyy-mm-dd format e.g. 2022-10-01
- enter end date in yyyy-mm-dd format e.g. 2022-10-03
- Creates a json text file with energy flow data

## GE-DataPoints.ps1
- Basic Script to retrieve data points for a day in json format
- edit to put in apikey and GivEnergy serial number
- edit to change grouping required Default 0 = 30 minutes
- Save and run in powershell with right click
- enter start date in yyyy-mm-dd format e.g. 2022-10-01
- Creates a json file with data points for that day
- Can be used to see what fields are available and allow other info to be extracted to csv files

## Example spreadsheet
Datapoint.ods (or .xls) are an example spreadsheet to collect the output from GE-DaysDataPoints.ps1
and summarise it. Open the txt file from running that script in a spreaadsheet program and then paste
the data from the 5 columns into the corresponding date area on the spreadsheet.
The sheet tab can be copied omto a new tab for further years.

FluxData.ods is a spreadsheet that works with Flux data from the DaysIntervalDataPoints script.
Open the output of the script in spreadsheet program using the csv format then copy and paste the data in the Time to Battery columns into the corresponding date rows of th emain spreadsheet.
The flux import and export rates may be edited in the rates sheet.