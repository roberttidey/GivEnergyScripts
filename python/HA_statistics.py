##Python script to transform statistics.json file from Home assistant into one or more csv files
import requests
from decimal import Decimal
from datetime import datetime, timedelta
import json
import os

os.chdir(os.path.dirname(os.path.realpath(__file__)))

datafilenamepath = "c:/users/{username}robert/Downloads/DataPoints_"
datafilename = ""
jsonfilename = "c:/users/{username}/Downloads/statistics.json"

## Modes has list of output file types to output
## Leave empty to enter manually
Modes = []

if len(Modes) == 0:
    Modes = input("Modes csv list (0=Sumary by day, 1=Summary by interval, 2=Full : ").split(',')
DataPointsStr = "Date,Period,Time,Solar,Import,Export,Consumption,Battery\n"
## default is for Flux periods in hours
IntervalTimes = [[23],[1,4,15,18,23],[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]]
FieldNames = ['pv_power','import_power','export_power','load_power','battery_soc']
data_values = [[] for i in range(5)]
parValues = [5]

TWOPLACES = Decimal('0.01')
daydates = []

def WriteCSV(mode):
    parArray = ["","","","","","",""]
    parValues = [0] * len(FieldNames)
    intervals = IntervalTimes[mode]
    interval = 0
    for rec in range(len(data_values[0])):
        for par in range(len(parValues) - 1):
            parValues[par] = parValues[par] + data_values[par][rec]
        parValues[len(parValues) - 1] = data_values[len(parValues) - 1][rec]
        if (rec % 24) == intervals[interval]:
            parArray[0] = str(interval)
            parArray[1] = str(rec % 24).rjust(2, '0') + ":59"
            parArray[2] = str(round(parValues[0]/1000,2))
            parArray[3] = str(round(parValues[1]/1000,2))
            parArray[4] = str(round(parValues[2]/1000,2))
            parArray[5] = str(round(parValues[3]/1000,2))
            parArray[6] = str(round(parValues[len(parValues) - 1]))
            day = rec // 24
            dateStr = daydates[day][6:10] + '-' +daydates[day][3:5] + '-' + daydates[day][0:2]
            DataPointsStr = dateStr + "," + ','.join(parArray) + "\n"
            with open(datafilename, 'a') as datafile:
                datafile.write(DataPointsStr)
            interval = interval + 1
            if interval >= len(intervals):
                interval = 0
            parValues = [0] * (len(FieldNames))
            
def GetFieldValues():
  with open(jsonfilename) as json_data:
    Data = json.load(json_data)
  ret = 0
  for index in range(len(FieldNames)):
      id = Data[index]["id"]
      fieldix = -1
      for match in range(len(FieldNames)):
          if id.find(FieldNames[match]) >= 0:
            fieldix = match
            break
      if fieldix < 0:
          print ("Bad field name ", id)
          ret = -1
          break
      values = len(Data[index]["values"])
      for value in range(values):
          data_values[fieldix].append(Data[index]["values"][value]["mean"])
  for fieldix in range(len(Data[0]["values"])):
      if (fieldix % 24) == 0:
          daydates.append(Data[0]["values"][fieldix]["datetime"])
  return ret 


if GetFieldValues() == 0:
    datestr = daydates[0][6:10] + daydates[0][3:5] + daydates[0][0:2]
    for Mode in Modes:
        datafilename = datafilenamepath + str(Mode) + "_" + datestr + ".txt"
        with open(datafilename, 'w') as datafile:
            datafile.write(DataPointsStr)
        WriteCSV(int(Mode))
        print ("Data saved to ", datafilename)
else:
   print ("Parsing values error")
