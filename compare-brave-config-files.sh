#!/bin/bash

jq '.' Preferences > temp 
jq 'del(.announcement_notification_service_first_run_time)' temp > temp2
rm temp
mv temp2 Preferences

jq '.' 'Local State' > temp && mv temp 'Local State'

jq '.' ~/.config/BraveSoftware/Brave-Browser/Default/Preferences > temp && mv temp ~/.config/BraveSoftware/Brave-Browser/Default/Preferences
jq '.' '/home/abdul/.config/BraveSoftware/Brave-Browser/Local State' > temp && mv temp '/home/abdul/.config/BraveSoftware/Brave-Browser/Local State'
