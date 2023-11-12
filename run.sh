#!/usr/bin/with-contenv bashio
while :
do
CONFIG_PATH=/data/options.json

sunsynk_user=""
sunsynk_pass=""
sunsynk_serial=""
HA_LongLiveToken=""

sunsynk_user="$(bashio::config 'sunsynk_user')"
sunsynk_pass="$(bashio::config 'sunsynk_pass')"
sunsynk_serial="$(bashio::config 'sunsynk_serial')"
HA_LongLiveToken="$(bashio::config 'HA_LongLiveToken')"

ServerAPIBearerToken=""
SolarInputData=""

echo "Setting user parameters."
#echo $sunsynk_user
#echo $sunsynk_pass
#echo $sunsynk_serial
#echo $HA_LongLiveToken

echo "Getting bearer code from solar service provider's API."
ServerAPIBearerToken=$(curl -s -X POST -H "Content-Type: application/json" https://api.sunsynk.net/oauth/token -d '{"areaCode": "sunsynk","client_id": "csp-web","grant_type": "password","password": "'"$sunsynk_pass"'","source": "sunsynk","username": "'"$sunsynk_user"'"}' | jq -r '.data.access_token')
#echo $ServerAPIBearerToken

echo "Please wait while curl is fetching input, grid, load, battery & output data..."
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial/realtime/input -o "pvindata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/grid/$sunsynk_serial/realtime?sn=$sunsynk_serial -o "griddata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/load/$sunsynk_serial/realtime?sn=$sunsynk_serial -o "loaddata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" "https://api.sunsynk.net/api/v1/inverter/battery/$sunsynk_serial/realtime?sn=$sunsynk_serial&lan=en" -o "batterydata.json"
curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial/realtime/output -o "outputdata.json"

#Unused
#curl -s -X GET -H "Content-Type: application/json" -H "authorization: Bearer $ServerAPIBearerToken" https://api.sunsynk.net/api/v1/inverter/$sunsynk_serial/flow -o "flowdata.json"
# Read Settings https://api.sunsynk.net/api/v1/common/setting/$sunsynk_serial/read
# Save Settings https://api.sunsynk.net/api/v1/common/setting/$sunsynk_serial/set


echo "Data fetched , see below data dump. If all values are NULL then something went wrong."
OutputVolt=$(jq -r '.data.vip[0].volt' outputdata.json)
OutputCurrent=$(jq -r '.data.vip[0].current' outputdata.json)
OutputPower=$(jq -r '.data.vip[0].power' outputdata.json)
OutputACFreq=$(jq -r '.data.fac' outputdata.json)
OutputPowerAC=$(jq -r '.data.pac' outputdata.json)
OutputPowerInv=$(jq -r '.data.pInv' outputdata.json)

SolInPV0Volt=$(jq -r '.data.pvIV[0].vpv' pvindata.json)
SolInPV1Volt=$(jq -r '.data.pvIV[1].vpv' pvindata.json)
SolInPV0Current=$(jq -r '.data.pvIV[0].ipv' pvindata.json)
SolInPV1Current=$(jq -r '.data.pvIV[1].ipv' pvindata.json)
SolInPV0Power=$(jq -r '.data.pvIV[0].ppv' pvindata.json)
SolInPV1Power=$(jq -r '.data.pvIV[1].ppv' pvindata.json)

GridVolt=$(jq -r '.data.vip[0].volt' griddata.json)
GridCurrent=$(jq -r '.data.vip[0].current' griddata.json)
GridPower=$(jq -r '.data.vip[0].power' griddata.json)
GridACFreq=$(jq -r '.data.fac' griddata.json)

LoadVolt=$(jq -r '.data.vip[0].volt' loaddata.json)
LoadCurrent=$(jq -r '.data.vip[0].current' loaddata.json)
LoadPower=$(jq -r '.data.vip[0].power' loaddata.json)
LoadACFreq=$(jq -r '.data.loadFac' loaddata.json)
LoadTotalUsed=$(jq -r '.data.totalUsed' loaddata.json)
LoadDailyUsed=$(jq -r '.data.dailyUsed' loaddata.json)
LoadTotalPower=$(jq -r '.data.totalPower' loaddata.json)
LoadUPSPowerL1=$(jq -r '.data.upsPowerL1' loaddata.json)
LoadUPSPowerL2=$(jq -r '.data.upsPowerL2' loaddata.json)
LoadUPSPowerL3=$(jq -r '.data.upsPowerL3' loaddata.json)
LoadUPSPowerTotal=$(jq -r '.data.upsPowerTotal' loaddata.json)

Battery1Volt=$(jq -r '.data.voltage' batterydata.json)
Battery1Current=$(jq -r '.data.current' batterydata.json)
Battery1Power=$(jq -r '.data.power' batterydata.json)
Battery1Temp=$(jq -r '.data.temp' batterydata.json)
Battery1SOC=$(jq -r '.data.soc' batterydata.json)
Battery1Capacity=$(jq -r '.data.capacity' batterydata.json)
Battery1Type=$(jq -r '.data.type' batterydata.json)

Battery2Volt=$(jq -r '.data.voltage2' batterydata.json)
Battery2Current=$(jq -r '.data.current2' batterydata.json)
Battery2Power=$(jq -r '.data.power2' batterydata.json)
Battery2Temp=$(jq -r '.data.temp2' batterydata.json)
Battery2SOC=$(jq -r '.data.soc2' batterydata.json)

BatteryChargeVolt=$(jq -r '.data.chargeVolt' batterydata.json)
BatteryStatus=$(jq -r '.data.status' batterydata.json)



echo "SolInPV0Volt" $SolInPV0Volt
echo "Volt1" $SolInPV1Volt
echo "SolInPV1Volt" $SolInPV0Current
echo "SolInPV1Current" $SolInPV1Current
echo "SolInPV0Power" $SolInPV0Power
echo "SolInPV1Power" $SolInPV1Power

echo "GridVolt" $GridVolt
echo "GridCurrent" $GridCurrent
echo "GridPower" $GridPower
echo "GridACFreq" $GridACFreq

echo "LoadVolt" $LoadVolt
echo "LoadCurrent" $LoadCurrent
echo "LoadPower" $LoadPower
echo "LoadACFreq" $LoadACFreq
echo "LoadTotalUsed" $LoadTotalUsed
echo "LoadDailyUsed" $LoadDailyUsed
echo "LoadTotalPower" $LoadTotalPower
echo "LoadUPSPowerL1" $LoadUPSPowerL1
echo "LoadUPSPowerL2" $LoadUPSPowerL2
echo "LoadUPSPowerL3" $LoadUPSPowerL3
echo "LoadUPSPowerTotal" $LoadUPSPowerTotal

echo "OutputVolt" $OutputVolt
echo "OutputCurrent" $OutputCurrent
echo "OutputPower" $OutputPower
echo "OutputACFreq" $OutputACFreq
echo "OutputPowerAC" $OutputPowerAC
echo "OutputPowerInv" $OutputPowerInv

echo "Battery1Volt" $Battery1Volt
echo "Battery1Current" $Battery1Current
echo "Battery1Power" $Battery1Power
echo "Battery1Temp" $Battery1Temp
echo "Battery1SOC" $Battery1SOC
echo "Battery1Capacity" $Battery1Capacity
echo "Battery1Type" $Battery1Type

echo "Battery2Volt" $Battery2Volt
echo "Battery2Current" $Battery2Current
echo "Battery2Power" $Battery2Power
echo "Battery2Temp" $Battery2Temp
echo "Battery2SOC" $Battery2SOC

echo "BatteryChargeVolt" $BatteryChargeVolt
echo "BatteryStatus" $BatteryStatus



#Update Sensors
echo "Updating Sensors"

curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$SolInPV0Volt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_solinpv0volt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$SolInPV1Volt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_volt1
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$SolInPV0Current"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_solinpv1volt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$SolInPV1Current"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_solinpv1current
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$SolInPV0Power"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_solinpv0power
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$SolInPV1Power"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_solinpv1power
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$GridVolt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_gridvolt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$GridCurrent"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_gridcurrent
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$GridPower"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_gridpower
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$GridACFreq"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_gridacfreq
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadVolt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadvolt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadCurrent"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadcurrent
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadPower"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadpower
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadACFreq"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadacfreq
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadTotalUsed"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadtotalused
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadDailyUsed"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loaddailyused
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadTotalPower"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadtotalpower
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadUPSPowerL1"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadupspowerl1
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadUPSPowerL2"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadupspowerl2
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadUPSPowerL3"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadupspowerl3
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$LoadUPSPowerTotal"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_loadupspowertotal
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$OutputVolt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_outputvolt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$OutputCurrent"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_outputcurrent
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$OutputPower"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_outputpower
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$OutputACFreq"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_outputacfreq
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$OutputPowerAC"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_outputpowerac
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$OutputPowerInv"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_outputpowerinv
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1Volt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1volt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1Current"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1current
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1Power"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1power
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1Temp"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1temp
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1SOC"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1soc
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1Capacity"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1capacity
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery1Type"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery1type
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery2Volt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery2volt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery2Current"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery2current
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery2Power"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery2power
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery2Temp"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery2temp
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$Battery2SOC"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_battery2soc
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$BatteryChargeVolt"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_batterychargevolt
curl -s -X POST -H "Authorization: Bearer $HA_LongLiveToken" -H "Content-Type: application/json" -d '{"state": "'"$BatteryStatus"'"}' http://192.168.1.8:8123/api/states/sensor.solarsynk_batterystatus

echo "All Done!"




sleep 300
done