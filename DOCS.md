![](https://github.com/martinville/solarsynk/blob/main/logo.png)

## How it works
SolarSynk will fetch solar system data via the internet which was initially posted to the cloud via your sunsynk dongle. It does not have any physical interfaces that are connected directly to your inverter. 
Please also note that this add-on only populates sensor values with data. It does not come with any cards to display information.

## Getting Started

In order for this add-on to work it needs to publish sensor values to Home Assistant's entities via the HA local API. Therefore a long-lived access token is required.

### Setting up a long-lived access token.
Click your profile picture situated in the bottom left of your HA user-interface. Scroll all the way to the bottom and create a long-lived token. The token name is not important for the solarsynk add-on but obviously the token key is. Make sure you copy it and keep it for use later on.

![](https://github.com/martinville/solarsynk/blob/main/longlivetoken.png)

### Provide your Sunsynk.net credentials
After installing this add-on make sure you enter all the required information on the configuration page. Note if your intentions are to update a Home Assistant installtion with a different IP than the one where this addon is installed, you need to generate the long live token on the Home Assistant instance where entities will be updated.

![](https://github.com/martinville/solarsynk/blob/main/configuration.png)

In case you are unsure what your Sunsynk inverter's serial number is. Log into the synsynk.net portal and copy the serial number from the "Inverter" menu item.

![](https://github.com/martinville/solarsynk/blob/main/sunserial.png)

Make sure you also populate the "HA_LongLiveToken" field with the long-lived token that you created earlier on.

### Start the script
After entering all of the required information you can go ahead and start the service script.

![](https://github.com/martinville/solarsynk/blob/main/solarsynkstarted.png)

Once started make sure all is ok by clicking on the "log" tab. Scroll through the log and check that the sensor data was populated correctly.
Few values will be null if you for instance only have a single string of solar panels. If something went wrong ALL of the sensors will have a "null" value. 


### Sensor data entities
Below is a list of sensor entities that will be populated.

sensor.solarsynk_solinpv0volt, 
sensor.solarsynk_volt1, 
sensor.solarsynk_solinpv1volt, 
sensor.solarsynk_solinpv1current, 
sensor.solarsynk_solinpv0power, 
sensor.solarsynk_solinpv1power, 
sensor.solarsynk_gridvolt, 
sensor.solarsynk_gridcurrent, 
sensor.solarsynk_gridpower, 
sensor.solarsynk_gridacfreq, 
sensor.solarsynk_loadvolt, 
sensor.solarsynk_loadcurrent, 
sensor.solarsynk_loadpower, 
sensor.solarsynk_loadacfreq, 
sensor.solarsynk_loadtotalused, 
sensor.solarsynk_loaddailyused, 
sensor.solarsynk_loadtotalpower, 
sensor.solarsynk_loadupspowerl1, 
sensor.solarsynk_loadupspowerl2, 
sensor.solarsynk_loadupspowerl3, 
sensor.solarsynk_loadupspowertotal, 
sensor.solarsynk_outputvolt, 
sensor.solarsynk_outputcurrent, 
sensor.solarsynk_outputpower, 
sensor.solarsynk_outputacfreq, 
sensor.solarsynk_outputpowerac, 
sensor.solarsynk_outputpowerinv, 
sensor.solarsynk_battery1volt, 
sensor.solarsynk_battery1current, 
sensor.solarsynk_battery1power, 
sensor.solarsynk_battery1temp, 
sensor.solarsynk_battery1soc, 
sensor.solarsynk_battery1capacity, 
sensor.solarsynk_battery1type, 
sensor.solarsynk_battery2volt, 
sensor.solarsynk_battery2current, 
sensor.solarsynk_battery2power, 
sensor.solarsynk_battery2temp, 
sensor.solarsynk_battery2soc, 
sensor.solarsynk_batterychargevolt, 
sensor.solarsynk_batterystatus,
