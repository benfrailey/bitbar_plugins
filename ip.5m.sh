#!/bin/bash

#source ~/.custom_commands.sh <- this was needed when "ip" was the command that was run instead of typing out the code from the command here

#Enable/disable flag for automatically turning wifi off if connected to ethernet



if [ "$1" == "toggleAutomaticOff" ]; then
    isEnabled=$(cat ~/bitbar_plugins/support_files/isEnabled)
    if [ "$isEnabled" == "true" ]; then
        echo "false" > ~/bitbar_plugins/support_files/isEnabled
    else
        echo "true" > ~/bitbar_plugins/support_files/isEnabled
    fi
fi

isEnabled=$(cat ~/bitbar_plugins/support_files/isEnabled)
    if [ "$isEnabled" == "true" ]; then
        automaticOffText="Disable"
    else
        automaticOffText="Enable"
    fi

# Set variable 'wifiAddress' to the address of interface en0 (known to be ethernet iface for this mac).
# '2> /dev/null' throws aways any error messages
wifiAddress=$(ipconfig getifaddr en0 2> /dev/null)
if [ $? -eq 1 ]; then

    if [ "$(networksetup -getairportpower en0 | grep On)" = "" ]; then
        wifiAddress="wifi off"
    else
	    # If previous command exited with an error, set 'wifiAddress' to 'not connected'
        wifiAddress="no wifi"
    fi
    
fi

# Set variable 'ethernetAddress' to the address of interface en5 (known to be ethernet iface for this mac).
# '2> /dev/null' throws aways any error messages
ethernetAddress=$(ipconfig getifaddr en5 2> /dev/null)

# If previous command exited with an error, set 'ethernetAddress' to 'not connected'
if [ $? -eq 1 ]; then
    ethernetAddress="not connected"
    networksetup -setairportpower en0 on
else
    if [ "$isEnabled" == "true" ]; then
        networksetup -setairportpower en0 off
    fi
    
fi

# If Save option clicked, caffeinate and save wifi address to google_drive/ip.txt
if [ "$1" = "save" ]; then
    sudo -S pmset -b sleep 0 && sudo -S pmset -b disablesleep 1

    # If wifi is off, turn it on
    if [ "$(networksetup -getairportpower en0 | grep On)" = "" ]; then
        networksetup -setairportpower en0 on
        # Wait to set 'wifiAddress' variable until an ip address is available
        while [ "$(ifconfig en0 | grep inet)" = "" ]; do
            sleep 2
        done
		#wifiAddress=$(ipconfig getifaddr en0)  <- apparently this updates after ifconfig, so there's a possibility this is empty even though there is a given ip address (had it happen once)
        wifiAddress=$(ifconfig en0 | grep 'inet ' | awk '{print $2}')
    fi
    echo $wifiAddress > ~/google_drive/ip.txt
    open bitbar://refreshPlugin?name=caffeine.5s.sh
fi

shortip=$(echo $wifiAddress | cut -d'.' -f 3,4) # Last 2 #s of wifi ip to display to menu bar

echo "$shortip | color=#0000FF"

echo ---

echo "Save and ☕️ | bash=$0 param1=save terminal=false "

echo ---

echo -e "wifi\t\t$wifiAddress"
echo -e "enet\t$ethernetAddress"

echo ---

if [ "$automaticOffText" == "Enable" ]; then
    echo "Wifi auto off: Disabled"
else
    echo "Wifi auto off: Enabled"
fi
echo "$automaticOffText | bash=$0 param1=toggleAutomaticOff terminal=false refresh=true "

echo ---

echo "Refresh | refresh=true"
echo "Edit plugin | bash=$0 param1=edit terminal=false "
if [ "$1" = "edit" ]; then
    open "${0}"
fi

#TODO
#Add enable and disable feature to the code that automatically turns off wifi when ethernet is connected