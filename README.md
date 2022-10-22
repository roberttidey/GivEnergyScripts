# GivEnergy API powershell scripts

## GE-DaysDataPoints.ps1
- Script to extract daily summary for a range of dates toa csv file
- edit to put in apikey and GivEnergy serial number
- edit $DateFirst to enter first date 
- edit $DateCount for number of days required
- Save and run in powershell with right click
- Creates a csv text file with fileds for date,solar,import, export,consumption and final battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extractin full data for each day, parsing into data object and looking for last entry which contains today totals
