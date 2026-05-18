import requests
from decimal import Decimal
from datetime import datetime, timedelta
import os

os.chdir(os.path.dirname(os.path.realpath(__file__)))

Cumulative = 0
GivEnergyPortalAPI = "apikey"
SerialNum = "serialno"

DateFirst = input("Enter start Date yyyy-MM-dd : ")
DatePick = DateFirst
DateCount = int(input("Enter number of days : "))
pageX = 1
pageSizeX = 1000
DataPointsStr = "Date,Period,Time,Solar,Import,Export,Consumption,Battery\n"
## If PeriodInterval is 0 then IntervalTimes are used else it sets a regular interval throughout the day e.g. 30 minutes
PeriodInterval = 0
## Intervaltimes array if PeriodInterval is 0.  Times in minutes in minutes
## default is for Flux periods
IntervalTimes = [120,300,960,1140,1440]
TWOPLACES = Decimal('0.01')

def justMinutes(tmpTime, offset):
  return (int(tmpTime[11:13]) * 60 + int(tmpTime[14:16]) + offset) % 1440

def formatMinutes(tmpMinutes):
  h = str(tmpMinutes // 60)
  if (len(h) == 1):
    h = "0" + h
  m = str(tmpMinutes % 60)
  if (len(m) == 1):
    m = "0" + m
  return h + ":" + m 

def WriteDateFluxData():
  GMTOffset = 0
  url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/data-points/" + DatePick + "?page=" + str(pageX) + "&pageSize=" + str(pageSizeX)
  headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}
  response = requests.get(url, headers = headers)
  Data = response.json()['data']
  last = len(Data)
  if(justMinutes(Data[0]['time'], GMTOffset) > 10):
    GMTOffset = 60
  period = 0
  nextPeriod = PeriodInterval
  solarlast = 0
  importlast = 0
  exportlast = 0
  consumptionlast = 0
  parArray = ["","","","","","",""]
  for rec in range(last):
    recminutes = justMinutes(Data[rec]['time'], GMTOffset)
    if(PeriodInterval == 0):
      nextPeriod = IntervalTimes[period]
    if(((recminutes > nextPeriod) and (nextPeriod < 1440)) or (rec == (last -1))):
      if(PeriodInterval > 0):
        nextPeriod = nextPeriod + PeriodInterval
      parArray[0] = str(period)
      parArray[1] = formatMinutes(recminutes)
      temp = Decimal(Data[rec]['today']['solar']).quantize(TWOPLACES)
      parArray[2] = str(temp - solarlast)
      if (Cumulative == 0):
        solarlast = temp
      temp = Decimal(Data[rec]['today']['grid']['import']).quantize(TWOPLACES)
      parArray[3] = str(temp - importlast)
      if (Cumulative == 0):
        importlast = temp
      temp = Decimal(Data[rec]['today']['grid']['export']).quantize(TWOPLACES)
      parArray[4] = str(temp - exportlast)
      if (Cumulative == 0):
        exportlast = temp
      temp = Decimal(Data[rec]['today']['consumption']).quantize(TWOPLACES)
      parArray[5] = str(temp - consumptionlast)
      if (Cumulative == 0):
        consumptionlast = temp
      parArray[6] = str(int(Data[rec]['power']['battery']['percent']))
      DataPointsStr = DatePick + "," + ','.join(parArray) + "\n"
      with open(datafilename, 'a') as datafile:
        datafile.write(DataPointsStr)
      period = period + 1
      
      
datafilename = ".\IntervalDataPoints_" + DateFirst + ".txt"

with open(datafilename, 'w') as datafile:
    datafile.write(DataPointsStr)

for index in range(DateCount):
  print (DatePick)
  WriteDateFluxData()
  date = datetime.strptime(DatePick, "%Y-%m-%d")
  date = date + timedelta(days=1)
  DatePick = datetime.strftime(date, "%Y-%m-%d")

print ("Data saved to ", datafilename)
