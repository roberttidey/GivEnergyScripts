# GivEnergy API powershell scripts and python equivalents

For Powershell you may have to enable running powershell scripts. Search for a guide on how to do this.
There are also python equivalents in the python folder. You may need to install the python requests module for these.
For Windows powershell scripts the easiest way to run is to right click the script file within file explorer.
For the python programs open a console window and run python <pythonscriptname>

You will need to edit the script before you can use it to add your inverter serial number and a GivEnergy Cloud API key.
To create an API key, in the GivEnergy Portal:
- Account Settings
- Manage Account Security
- Manage API Tokens
- Generate New Token
- Give the token a name, an expiry date and ensure that `api:inverter:data` and `api:meter:data` are selected
- Create token
- Click the copy icon to copy the token to your clipboard, then paste it into the script

## GE-DaysDataPoints
- Script to extract daily summary for a range of dates to a csv file
- edit to put in apikey and GivEnergy serial number
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields for date,solar,import, export,consumption and final battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extracting full data for each day, parsing into data object and looking for last entry which contains today totals

## GE-DaysFullDataPoints
- Script to extract data at 5 mminute intervals for a range of dates to a csv file
- edit to put in apikey and GivEnergy serial number
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields for date/time, solar today, solar total, import today, import total, export today, import total, consumption today, consumption total, battery charge today, battery discharge today and battery percentage
- Other fields can be addded easily by extracting from JSON data object 
- Works by extracting full data for each day, parsing into data object and iterating over all records

## GE-DaysIntervalDataPoints
- Script to extract data over periods per day for a range of dates to a csv file
- edit to put in apikey and GivEnergy serial number
- enter first date in yyyy-mm-dd format e.g. 2022-10-01
- enter number of days required
- Creates a csv text file with fields date, periodindex,time,solar,import, export,consumption and battery percentage
- Energy values are kwH. If $Cumulative variable in script is set to 1 then values are running total. If 0 then they are the value in that period.
- Periods can be regular times set by $periodInterval in minutes
- If $periodInterval is set to 0 then an array of fixed times in minutes is used ($IntervalTimes)
- The default $IntervalTimes is for Octopus Flux 
- Works by extracting full data for each day, parsing into data object and iterating over all records looking for the period data

## GET-EnergyFlow
- Script to extract energyflow data
- edit to put in apikey and GivEnergy serial number
- edit to change grouping required Default 0 = 30 minutes
- edit to change id types required Default 0,1,2,3,4,5
- enter start date in yyyy-mm-dd format e.g. 2022-10-01
- enter end date in yyyy-mm-dd format e.g. 2022-10-03
- Creates a json text file with energy flow data

## GET-DataPoints
- Basic Script to retrieve data points for a day in json format
- edit to put in apikey and GivEnergy serial number
- edit to change grouping required Default 0 = 30 minutes
- enter start date in yyyy-mm-dd format e.g. 2022-10-01
- Creates a json file with data points for that day
- Can be used to see what fields are available and allow other info to be extracted to csv files

## GE_LatestSystemData
- Creates a csv text file with latest system data as a json file

## Example spreadsheet
Datapoint.ods (or .xls) are an example spreadsheet to collect the output from GE-DaysDataPoints.ps1
and summarise it. Open the txt file from running that script in a spreaadsheet program and then paste
the data from the 5 columns into the corresponding date area on the spreadsheet.
The sheet tab can be copied onto a new tab for further years.

FluxData.ods is a spreadsheet that works with Flux data from the DaysIntervalDataPoints script.
Open the output of the script in spreadsheet program using the csv format then copy and paste the data in the Time to Battery columns into the corresponding date rows of th emain spreadsheet.
The flux import and export rates may be edited in the rates sheet. Multiple rates tables may be entered as prices vary. The main data sheets have a rates column which should contain the row number of the first rates line in each table.

## Experimental HomeAssistant statistics - python
HA_statistics.py is a python program to transform the long term GivEnergy statistics into a compatible form as the existing GivEnergy api versions.

The intention is to keep existing functionality even when the ai is no longer freely available.
Prerequisites are a HomeAssistant server with GivTCP added and the import_statistics integration added (which includes an export statistics function.
https://github.com/klausj1/homeassistant-statistics

The import_statistics.export_statistics action is configures to export to statistics.json and with entities
- sensor.givtcp_ce12345678_pv_power
- sensor.givtcp_ce12345678_import_power
- sensor.givtcp_ce12345678_export_power
- sensor.givtcp_ce12345678_load_power
- sensor.givtcp_bece12345678_battery_soc
replace the ids with your own

The start time and end time dates should be set to the first and last dates and the time must be set to 00:00:00 in both cases

The perform action button will then produce a statistics.json file with that entity data.

The statistics.json file is in the homeassistant folder and may be downloaded using the file editor. 

The HA_statistics file needs to have the jsonfilename and the datafilename configured. E.g. the [user] field should be replaced with your username if on a windows machine.

When run it offers a choice of 3 different outputs
  0) Summary line per day
  1) Summary for a number of intervals during each day like Octopus Flux
  2) Hourly data during each day  
  
The output is a csv file which may be opened with a spreadheet program

Possible enhancements are to add further integration in HomeAssistant to make to reduce the number of steps needed.