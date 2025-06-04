import requests
import os

os.chdir(os.path.dirname(os.path.realpath(__file__)))

GivEnergyPortalAPI = "apikey"
SerialNum = "serialno"
DateStart = input("Enter Start Date yyyy-MM-dd ")
DateEnd = input("Enter End Date yyyy-MM-dd ")

url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/energy-flows"
headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}
body = "{\"start_time\": \"" + DateStart + "\",\"end_time\": \"" + DateEnd + "\",\"grouping\": 0,\"types\": [0,1,2,3,4,5,6]}"
response = requests.post(url, headers = headers, data = body)
if response.status_code == 200:
  datafilename = ".\EnergyFlows_" + DateStart + ".json"

  with open(datafilename, 'w') as datafile:
      datafile.write(response.text)
  print ("Data saved to ", datafilename)

else:
  print ("Error = ", response.status_code)
