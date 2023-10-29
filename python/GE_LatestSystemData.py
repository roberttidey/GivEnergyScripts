import requests

GivEnergyPortalAPI = "apikey"
SerialNum = "serialno"

url = "https://api.givenergy.cloud/v1/inverter/" + SerialNum + "/system-data/latest"
#payload = {'inverter_serials': "['" + SerialNum + "']", 'setting_id': 17}
headers = {'Authorization': "Bearer " + GivEnergyPortalAPI,'Content-Type' : 'application/json','Accept' : 'application/json'}

response = requests.get(url, headers = headers)
if response.status_code == 200:
  datafilename = ".\LatestSystemData.json"

  with open(datafilename, 'w') as datafile:
      datafile.write(response.text)
  print ("Data saved to ", datafilename)

else:
  print ("Error = ", response.status_code)