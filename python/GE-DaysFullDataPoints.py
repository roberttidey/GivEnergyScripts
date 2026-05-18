import requests
from decimal import Decimal
from datetime import datetime, timedelta
import pytz
import os

TIMEZONE = pytz.timezone('Europe/London')

os.chdir(os.path.dirname(os.path.realpath(__file__)))

GivEnergyPortalAPI = "apikey"
SerialNum = "serialno"

DateFirst = input("Enter start Date yyyy-MM-dd : ")
DatePick = DateFirst
DateCount = int(input("Enter number of days : "))
pageX = 1
pageSizeX = 1000
DataPointsStr = "Date,Solar Today,Solar Total,Import Today,Import Total,Export Today,Export Total,Consumption Today,Consumption Total,Charge Today,Discharge Today,Battery SoC %\n"

TWOPLACES = Decimal('0.01')

def localTimeStamp(timestamp):
    # Take an XML date (2013-04-08T22:35:00Z)
    # return e.g. 08/04 23:35
    utc_dt = datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%SZ')
    bst = utc_dt.replace(tzinfo=pytz.utc).astimezone(TIMEZONE)
    return bst.strftime('%Y-%m-%d %H:%M:%S')

def WriteDateFullData():
  GMTOffset = 0
  url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/data-points/" + DatePick + "?page=" + str(pageX) + "&pageSize=" + str(pageSizeX)
  headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}
  response = requests.get(url, headers = headers)
  Data = response.json()['data']
  last = len(Data)
  parArray = ["","","","","","","","","","","",""]
  for rec in range(last):
    parArray[0] = localTimeStamp(Data[rec]['time'])
    parArray[1] = str(Decimal(Data[rec]['today']['solar']).quantize(TWOPLACES))
    parArray[2] = str(Decimal(Data[rec]['total']['solar']).quantize(TWOPLACES))
    parArray[3] = str(Decimal(Data[rec]['today']['grid']['import']).quantize(TWOPLACES))
    parArray[4] = str(Decimal(Data[rec]['total']['grid']['import']).quantize(TWOPLACES))
    parArray[5] = str(Decimal(Data[rec]['today']['grid']['export']).quantize(TWOPLACES))
    parArray[6] = str(Decimal(Data[rec]['total']['grid']['export']).quantize(TWOPLACES))
    parArray[7] = str(Decimal(Data[rec]['today']['consumption']).quantize(TWOPLACES))
    parArray[8] = str(Decimal(Data[rec]['total']['consumption']).quantize(TWOPLACES))
    parArray[9] = str(Decimal(Data[rec]['today']['battery']['charge']).quantize(TWOPLACES))
    parArray[10] = str(Decimal(Data[rec]['today']['battery']['discharge']).quantize(TWOPLACES))
    parArray[11] = str(int(Data[rec]['power']['battery']['percent']))
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
