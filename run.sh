#!/usr/bin/with-contenv bashio
while :
do
CONFIG_PATH=/data/options.json

sunsynk_user=""
sunsynk_pass=""
sunsynk_serial=""
HA_LongLiveToken=""
Home_Assistant_IP=""

sunsynk_user="$(bashio::config 'sunsynk_user')"
sunsynk_pass="$(bashio::config 'sunsynk_pass')"
sunsynk_serial="$(bashio::config 'sunsynk_serial')"
HA_LongLiveToken="$(bashio::config 'HA_LongLiveToken')"
Home_Assistant_IP="$(bashio::config 'Home_Assistant_IP')"
Refresh_rate="$(bashio::config 'Refresh_rate')"

ServerAPIBearerToken=""
SolarInputData=""
echo ""
echo ------------------------------------------------------------------------------
echo -- SolarSynk - Log
echo ------------------------------------------------------------------------------
echo "Setting user parameters."
#echo $sunsynk_user
#echo $sunsynk_pass
#echo $sunsynk_serial
#echo $HA_LongLiveToken

echo "Getting bearer token from solar service provider's API."
ServerAPIBearerToken=$(curl -s -X POST -H "Content-Type: application/json" https://api.sunsynk.net/oauth/token -d '{"areaCode": "sunsynk","client_id": "csp-web","grant_type": "password","password": "'"$sunsynk_pass"'","source": "sunsynk","username": "'"$sunsynk_user"'"}' | jq -r '.data.access_token')
echo $ServerAPIBearerToken
echo "Refresh rate set to:" $Refresh_rate "seconds."
echo "Note: Setting the refresh rate lower than the update rate of SunSynk is pointless and will just result in wasted disk space."


echo ""
echo "Cleaning up old data."
rm -rf pvindata.json
rm -rf griddata.json
rm -rf loaddata.json
rm -rf batterydata.json
rm -rf outputdata.json
rm -rf inverterinfo.json

echo "Please wait while curl is fetching input, grid, load, battery & output data..."
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial/realtime/input -o "pvindata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/grid/$sunsynk_serial/realtime?sn=$sunsynk_serial -o "griddata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/load/$sunsynk_serial/realtime?sn=$sunsynk_serial -o "loaddata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" "https://api.sunsynk.net/api/v1/inverter/battery/$sunsynk_serial/realtime?sn=$sunsynk_serial&lan=en" -o "batterydata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial/realtime/output -o "outputdata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial  -o "inverterinfo.json"


inverterinfo_brand=$(jq -r '.data.brand' inverterinfo.json)
inverterinfo_status=$(jq -r '.data.status' inverterinfo.json)
inverterinfo_runstatus=$(jq -r '.data.runStatus' inverterinfo.json)
inverterinfo_ratepower=$(jq -r '.data.ratePower' inverterinfo.json)
inverterinfo_plantid=$(jq -r '.data.plant.id' inverterinfo.json)
inverterinfo_plantname=$(jq -r '.data.plant.name' inverterinfo.json)
inverterinfo_serial=$(jq -r '.data.sn' inverterinfo.json)

echo ------------------------------------------------------------------------------
echo "Inverter Information"
echo "Brand:" $inverterinfo_brand
echo "Status:" $inverterinfo_runstatus
echo "Max Watts:" $inverterinfo_ratepower
echo "Plant ID:" $inverterinfo_plantid
echo "Plant Name:" $inverterinfo_plantname
echo "Inverter S/N:" $inverterinfo_serial
echo ------------------------------------------------------------------------------

#Unused
#curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial/flow -o "flowdata.json"
# Read Settings https://api.sunsynk.net/api/v1/common/setting/$sunsynk_serial/read
# Save Settings https://api.sunsynk.net/api/v1/common/setting/$sunsynk_serial/set


echo "Data fetched , see below data dump. If all values are NULL then something went wrong."
#Total Battery
battery_capacity=$(jq -r '.data.capacity' batterydata.json)
battery_chargevolt=$(jq -r '.data.chargeVolt' batterydata.json)
battery_current=$(jq -r '.data.current' batterydata.json)
battery_dischargevolt=$(jq -r '.data.dischargeVolt' batterydata.json)
battery_power=$(jq -r '.data.power' batterydata.json)
battery_soc=$(jq -r '.data.soc' batterydata.json)
battery_temperature=$(jq -r '.data.temp' batterydata.json)
battery_type=$(jq -r '.data.type' batterydata.json)
battery_voltage=$(jq -r '.data.voltage' batterydata.json)
#Battery 1
battery1_voltage=$(jq -r '.data.batteryVolt1' batterydata.json)
battery1_current=$(jq -r '.data.batteryCurrent1' batterydata.json)
battery1_power=$(jq -r '.data.batteryPower1' batterydata.json)
battery1_soc=$(jq -r '.data.batterySoc1' batterydata.json)
battery1_temperature=$(jq -r '.data.batteryTemp1' batterydata.json)
battery1_status=$(jq -r '.data.batteryStatus1' batterydata.json)
#Battery 2
battery2_voltage=$(jq -r '.data.batteryVolt2' batterydata.json)
battery2_current=$(jq -r '.data.batteryCurrent2' batterydata.json)
battery2_power=$(jq -r '.data.batteryPower2' batterydata.json)
battery2_soc=$(jq -r '.data.batterySoc2' batterydata.json)
battery2_temperature=$(jq -r '.data.batteryTemp2' batterydata.json)
battery2_status=$(jq -r '.data.batteryStatus2' batterydata.json)


day_battery_charge=$(jq -r '.data.etodayChg' batterydata.json)
day_battery_discharge=$(jq -r '.data.etodayDischg' batterydata.json)
day_grid_export=$(jq -r '.data.etodayTo' griddata.json)
day_grid_import=$(jq -r '.data.etodayFrom' griddata.json)
day_load_energy=$(jq -r '.data.dailyUsed' loaddata.json)
day_pv_energy=$(jq -r '.data.etoday' pvindata.json)
grid_connected_status=$(jq -r '.data.status' griddata.json)
grid_frequency=$(jq -r '.data.fac' griddata.json)
grid_power=$(jq -r '.data.vip[0].power' griddata.json)
grid_voltage=$(jq -r '.data.vip[0].volt' griddata.json)
grid_current=$(jq -r '.data.vip[0].current' griddata.json)
inverter_current=$(jq -r '.data.vip[0].current' outputdata.json)
inverter_frequency=$(jq -r '.data.fac' outputdata.json)
inverter_power=$(jq -r '.data.vip[0].power' outputdata.json)
inverter_voltage=$(jq -r '.data.vip[0].volt' outputdata.json)
load_current=$(jq -r '.data.vip[0].current' loaddata.json)
load_frequency=$(jq -r '.data.loadFac' loaddata.json)
load_power=$(jq -r '.data.vip[0].power' loaddata.json)
load_totalpower=$(jq -r '.data.totalPower' loaddata.json)
load_voltage=$(jq -r '.data.vip[0].volt' loaddata.json)
pv1_current=$(jq -r '.data.pvIV[0].ipv' pvindata.json)
pv1_power=$(jq -r '.data.pvIV[0].ppv' pvindata.json)
pv1_voltage=$(jq -r '.data.pvIV[0].vpv' pvindata.json)
pv2_current=$(jq -r '.data.pvIV[1].ipv' pvindata.json)
pv2_power=$(jq -r '.data.pvIV[1].ppv' pvindata.json)
pv2_voltage=$(jq -r '.data.pvIV[1].vpv' pvindata.json)
overall_state=$(jq -r '.data.runStatus' inverterinfo.json)





echo "battery_capacity" $battery_capacity
echo "battery_chargevolt" $battery_chargevolt
echo "battery_current" $battery_current
echo "battery_dischargevolt" $battery_dischargevolt
echo "battery_power" $battery_power
echo "battery_soc" $battery_soc
echo "battery_temperature" $battery_temperature
echo "battery_type" $battery_type
echo "battery_voltage" $battery_voltage
echo "day_battery_charge" $day_battery_charge
echo "day_battery_discharge" $day_battery_discharge
#Battery 1
echo "battery1_voltage" $battery1_voltage
echo "battery1_current" $battery1_current
echo "battery1_power" $battery1_power
echo "battery1_soc" $battery1_soc
echo "battery1_temperature" $battery1_temperature
echo "battery1_status" $battery1_status
#Battery 2
echo "battery2_voltage" $battery2_voltage
echo "battery2_current" $battery2_current
echo "battery2_power" $battery2_power
echo "battery2_soc" $battery2_soc
echo "battery2_temperature" $battery2_temperature
echo "battery2_status" $battery2_status

echo "day_grid_export" $day_grid_export
echo "day_grid_import" $day_grid_import
echo "day_load_energy" $day_load_energy
echo "day_pv_energy" $day_pv_energy
echo "grid_connected_status" $grid_connected_status
echo "grid_frequency" $grid_frequency
echo "grid_power" $grid_power
echo "grid_voltage" $grid_voltage
echo "grid_current" $grid_current
echo "inverter_current" $inverter_current
echo "inverter_frequency" $inverter_frequency
echo "inverter_power" $inverter_power
echo "inverter_voltage" $inverter_voltage
echo "load_current" $load_current
echo "load_frequency" $load_frequency
echo "load_power" $load_power
echo "load_totalpower" $load_totalpower
echo "load_voltage" $load_voltage
echo "pv1_current" $pv1_current
echo "pv1_power" $pv1_power
echo "pv1_voltage" $pv1_voltage
echo "pv2_current" $pv2_current
echo "pv2_power" $pv2_power
echo "pv2_voltage" $pv2_voltage
echo "overall_state" $overall_state






echo ------------------------------------------------------------------------------
echo "Updating the following sensor entities"
echo ------------------------------------------------------------------------------
#Battery Stuff
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"unit_of_measurement": "Ah", "friendly_name": "Battery Capacity"}, "state": "'"$battery_capacity"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_capacity | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Battery Charge Voltage"}, "state": "'"$battery_chargevolt"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_chargevolt | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "Battery Current"}, "state": "'"$battery_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_current | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Battery Discharge Voltage"}, "state": "'"$battery_dischargevolt"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_dischargevolt | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Battery Power"}, "state": "'"$battery_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_power | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power_factor", "state_class":"measurement", "unit_of_measurement": "%", "friendly_name": "Battery SOC"}, "state": "'"$battery_soc"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_soc | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "temperature", "state_class":"measurement", "unit_of_measurement": "°C", "friendly_name": "Battery Temp"}, "state": "'"$battery_temperature"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_temperature | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"unit_of_measurement": "", "friendly_name": "Battery Type"}, "state": "'"$battery_type"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_type | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Battery Voltage"}, "state": "'"$battery_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_voltage | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "energy", "state_class":"total_increasing", "unit_of_measurement": "kWh", "friendly_name": "Daily Battery Charge"}, "state": "'"$day_battery_charge"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_day_battery_charge | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "energy", "state_class":"total_increasing", "unit_of_measurement": "kWh", "friendly_name": "Daily Battery Discsharge"}, "state": "'"$day_battery_discharge"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_day_battery_discharge | jq -r '.entity_id'
#Battery 1
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Battery 1 Charge Voltage"}, "state": "'"$battery1_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_chargevolt1 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "Battery 1 Current"}, "state": "'"$battery1_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_current1 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Battery 1 Power"}, "state": "'"$battery1_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_power1 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power_factor", "state_class":"measurement", "unit_of_measurement": "%", "friendly_name": "Battery 1 SOC"}, "state": "'"$battery1_soc"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_soc1 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "temperature", "state_class":"measurement", "unit_of_measurement": "°C", "friendly_name": "Battery 1 Temp"}, "state": "'"$battery1_temperature"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_temperature1 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"unit_of_measurement": "", "friendly_name": "Battery 1 Status"}, "state": "'"$battery1_status"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery1_status | jq -r '.entity_id'
#Battery 2
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Battery 2 Charge Voltage"}, "state": "'"$battery2_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_chargevolt2 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "Battery 2 Current"}, "state": "'"$battery2_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_current2 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Battery 2 Power"}, "state": "'"$battery2_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_power2 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power_factor", "state_class":"measurement", "unit_of_measurement": "%", "friendly_name": "Battery 2 SOC"}, "state": "'"$battery2_soc"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_soc2 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "temperature", "state_class":"measurement", "unit_of_measurement": "°C", "friendly_name": "Battery 2 Temp"}, "state": "'"$battery2_temperature"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery_temperature2 | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"unit_of_measurement": "", "friendly_name": "Battery 2 Status"}, "state": "'"$battery2_status"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_battery2_status | jq -r '.entity_id'
#Daily Generation
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "energy", "state_class":"total_increasing", "unit_of_measurement": "kWh", "friendly_name": "Daily Grid Export"}, "state": "'"$day_grid_export"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_day_grid_export | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "energy", "state_class":"total_increasing", "unit_of_measurement": "kWh", "friendly_name": "Daily Grid Import"}, "state": "'"$day_grid_import"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_day_grid_import | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "energy", "state_class":"total_increasing", "unit_of_measurement": "kWh", "friendly_name": "Daily Load Energy"}, "state": "'"$day_load_energy"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_day_load_energy | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "energy", "state_class":"total_increasing", "unit_of_measurement": "kWh", "friendly_name": "Daily PV energy"}, "state": "'"$day_pv_energy"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_day_pv_energy | jq -r '.entity_id'
# Grid
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"unit_of_measurement": "", "friendly_name": "Grid Connection Status"}, "state": "'"$grid_connected_status"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_grid_connected_status | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "frequency", "state_class":"measurement", "unit_of_measurement": "Hz", "friendly_name": "Grid Freq"}, "state": "'"$grid_frequency"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_grid_frequency | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Grid Power"}, "state": "'"$grid_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_grid_power | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Grid Voltage"}, "state": "'"$grid_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_grid_voltage | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "Grid Current"}, "state": "'"$grid_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_grid_current | jq -r '.entity_id'
#Inverter
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "Inverter Current"}, "state": "'"$inverter_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_inverter_current | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "frequency", "state_class":"measurement", "unit_of_measurement": "Hz", "friendly_name": "Inverter Freq"}, "state": "'"$inverter_frequency"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_inverter_frequency | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Inverter Power"}, "state": "'"$inverter_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_inverter_power | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Inverter Voltage"}, "state": "'"$inverter_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_inverter_voltage | jq -r '.entity_id'
#Load
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "Load Current"}, "state": "'"$load_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_load_current | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "frequency", "state_class":"measurement", "unit_of_measurement": "Hz", "friendly_name": "Load Freq"}, "state": "'"$load_frequency"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_load_frequency | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Load Power"}, "state": "'"$load_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_load_power | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "Load Total Power"}, "state": "'"$load_totalpower"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_load_totalpower | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "Load Voltage"}, "state": "'"$load_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_load_voltage | jq -r '.entity_id'
#SolarPanels
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "PV1 Current"}, "state": "'"$pv1_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_pv1_current | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "PV1 Power"}, "state": "'"$pv1_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_pv1_power | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "PV1 Voltage"}, "state": "'"$pv1_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_pv1_voltage | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "current", "state_class":"measurement", "unit_of_measurement": "A", "friendly_name": "PV2 Current"}, "state": "'"$pv2_current"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_pv2_current | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "power", "state_class":"measurement", "unit_of_measurement": "W", "friendly_name": "PV2 Power"}, "state": "'"$pv2_power"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_pv2_power | jq -r '.entity_id'
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"device_class": "voltage", "state_class":"measurement", "unit_of_measurement": "V", "friendly_name": "PV2 Voltage"}, "state": "'"$pv2_voltage"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_pv2_voltage | jq -r '.entity_id'
#Other
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"attributes": {"unit_of_measurement": "", "friendly_name": "Inverter Overall State"}, "state": "'"$overall_state"'"}' http://$Home_Assistant_IP:8123/api/states/sensor.solarsynk_overall_state | jq -r '.entity_id'


echo "All Done! Waiting " $Refresh_rate " sesonds to rinse and repeat."


sleep $Refresh_rate
done
