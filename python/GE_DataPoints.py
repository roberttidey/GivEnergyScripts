import requests
from decimal import Decimal
from datetime import datetime, timedelta
import os

os.chdir(os.path.dirname(os.path.realpath(__file__)))

Cumulative = 0
GivEnergyPortalAPI = "apikey"
SerialNum = "serialno"

DatePick = input("Enter start Date yyyy-MM-dd : ")
pageX = 1
pageSizeX = 1000

url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/data-points/" + DatePick + "?page=" + str(pageX) + "&pageSize=" + str(pageSizeX)
headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}
response = requests.get(url, headers = headers)
if response.status_code == 200:
  datafilename = ".\DataPoints_" + DatePick + ".json"

  with open(datafilename, 'w') as datafile:
      datafile.write(response.text)
  print ("Data saved to ", datafilename)

else:
  print ("Error = ", response.status_code)
