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
TWOPLACES = Decimal('0.01')

def WriteDayData():
  GMTOffset = 0
  url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/data-points/" + DatePick + "?page=" + str(pageX) + "&pageSize=" + str(pageSizeX)
  headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}
  response = requests.get(url, headers = headers)
  Data = response.json()['data']
  last = len(Data) - 1
  parArray = ["","","","",""]
  parArray[0] = str(Decimal(Data[last]['today']['solar']).quantize(TWOPLACES))
  parArray[1] = str(Decimal(Data[last]['today']['grid']['import']).quantize(TWOPLACES))
  parArray[2] = str(Decimal(Data[last]['today']['grid']['export']).quantize(TWOPLACES))
  parArray[3] = str(Decimal(Data[last]['today']['consumption']).quantize(TWOPLACES))
  parArray[4] = str(int(Data[last]['power']['battery']['percent']))
  DataPointsStr = DatePick + "," + ','.join(parArray) + "\n"
  with open(datafilename, 'a') as datafile:
    datafile.write(DataPointsStr)
      
      
datafilename = ".\DaysDataPoints_" + DateFirst + ".txt"

with open(datafilename, 'w') as datafile:
    datafile.write(DataPointsStr)

for index in range(DateCount):
  print (DatePick)
  WriteDayData()
  date = datetime.strptime(DatePick, "%Y-%m-%d")
  date = date + timedelta(days=1)
  DatePick = datetime.strftime(date, "%Y-%m-%d")

print ("Data saved to ", datafilename)
