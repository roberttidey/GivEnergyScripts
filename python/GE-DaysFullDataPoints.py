import requests
from decimal import Decimal
from datetime import datetime, timedelta

GivEnergyPortalAPI = "apikey"
SerialNum = "serialno"

DateFirst = input("Enter start Date yyyy-MM-dd : ")
DatePick = DateFirst
DateCount = int(input("Enter number of days : "))
pageX = 1
pageSizeX = 1000
DataPointsStr = "Date,Solar,Import,Export,Consumption,Battery\n"
## If PeriodInterval is 0 then IntervalTimes are used else it sets a regular interval throughout the day e.g. 30 minutes
TWOPLACES = Decimal('0.01')

def WriteDateFullData():
  GMTOffset = 0
  url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/data-points/" + DatePick + "?page=" + str(pageX) + "&pageSize=" + str(pageSizeX)
  headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}
  response = requests.get(url, headers = headers)
  Data = response.json()['data']
  last = len(Data)
  parArray = ["","","","","",""]
  for rec in range(last):
    parArray[0] = Data[rec]['time']
    parArray[1] = str(Decimal(Data[rec]['today']['solar']).quantize(TWOPLACES))
    parArray[2] = str(Decimal(Data[rec]['today']['grid']['import']).quantize(TWOPLACES))
    parArray[3] = str(Decimal(Data[rec]['today']['grid']['export']).quantize(TWOPLACES))
    parArray[4] = str(Decimal(Data[rec]['today']['consumption']).quantize(TWOPLACES))
    parArray[5] = str(int(Data[rec]['power']['battery']['percent']))
    DataPointsStr = ','.join(parArray) + "\n"
    with open(datafilename, 'a') as datafile:
      datafile.write(DataPointsStr)
      
      
datafilename = ".\FullDataPoints_" + DateFirst + ".txt"

with open(datafilename, 'w') as datafile:
    datafile.write(DataPointsStr)

for index in range(DateCount):
  print (DatePick)
  WriteDateFullData()
  date = datetime.strptime(DatePick, "%Y-%m-%d")
  date = date + timedelta(days=1)
  DatePick = datetime.strftime(date, "%Y-%m-%d")

print ("Data saved to ", datafilename)
