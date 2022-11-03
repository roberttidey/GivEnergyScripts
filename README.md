# GivEnergy API powershell scripts

## GE-DaysDataPoints.ps1
- Script to extract daily summary for a range of dates toa csv file
- edit to put in apikey and GivEnergy serial number
- Save and run in powershell with right click
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields for date,solar,import, export,consumption and final battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extractign full data for each day, parsing into data object and looking for last entry which contains today totals

## GE-DaysFullDataPoints.ps1
- Script to extract data at 5 mminute intervals for a range of dates toa csv file
- edit to put in apikey and GivEnergy serial number
- Save and run in powershell with right click
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields for time,solar,import, export,consumption and battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extracting full data for each day, parsing into data object and iterating over all records

## GE-EnergyFlow.ps1
- Script to extract energyflow data
- edit to put in apikey and GivEnergy serial number
- edit to change grouping required Default 0 = 30 minutes
- edit to change id types required Default 0,1,2,3,4,5
- Save and run in powershell with right click
- enter start date in yyyy-mm-dd format e.g. 2022-10-01
- enter end date in yyyy-mm-dd format e.g. 2022-10-03
- Creates a json text file with energy flow data
