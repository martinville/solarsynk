## How it works
SolarSynk will fetch solar system data via the internet which was initially posted to the cloud via your sunsynk dongle. It does not have any physical interfaces that are connected directly to your inverter. 

## Getting Started

In order for this add-on to work it needs to publish sensor values to Home Assistant's entities via the HA local API. Therefore a long-lived access token is required.

###Setting up a long-lived access token.
Click your profile picture situated in the bottom left of your HA user-interface. Scroll all the way to the bottom and create a long-lived token. The token name is not important for the solarsynk add-on but obviously the token key is. Make sure you copy it and keep it for use later on.

![](https://github.com/martinville/solarsynk/blob/main/longlivetoken.png)

###Provide your Sunsynk.net credentials
After installing this add-on make sure you enter all the required information on the configuration page.

![](https://github.com/martinville/solarsynk/blob/main/configuration.png)

In case you are unsure what your Sunsynk inverter's serial number is. Log into the synsynk.net portal and copy the serial number from the "Inverter" menu item.
![](https://github.com/martinville/solarsynk/blob/main/sunserial.png)
