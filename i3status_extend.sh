#!/bin/bash
# Shell script to prepend i3status with weather, VPN status and other things

  # make sure we use non-unicode character type locale
  # (that way it works for any locale as long as the font supports the characters)

#spin='⣾⣽⣻⢿⡿⣟⣯⣷'
#spin='⠁⠂⠄⡀⢀⠠⠐⠈'
spin="🌏🌎🌍"
#spin=["🌍 ", "🌎 ","🌏 "]
spinloc=0

temps[35]="#FF0000";
temps[34]="#FF1400";
temps[33]="#FF2800";
temps[32]="#FF3C00";
temps[31]="#FF5000";
temps[30]="#FF6400";
temps[29]="#FF7800";
temps[28]="#FF8C00";
temps[27]="#FFA000";
temps[26]="#FFB400";
temps[25]="#FFC800";
temps[24]="#FFDC00";
temps[23]="#FFF000";
temps[22]="#FDFF00";
temps[21]="#B0FF00";
temps[20]="#65FF00";
temps[19]="#3EFF00";
temps[18]="#17FF00";
temps[17]="#00FF10";
temps[16]="#00FF36";
temps[15]="#00FF5C";
temps[14]="#00FF83";
temps[13]="#00FFA8";
temps[12]="#00FFD0";
temps[11]="#00FFF4";
temps[10]="#00E4FF";
temps[9]="#00D4FF";
temps[8]="#00C4FF";
temps[7]="#00B4FF";
temps[6]="#00A4FF";
temps[5]="#0094FF";
temps[4]="#0084FF";
temps[3]="#0074FF";
temps[2]="#0064FF";
temps[1]="#0054FF";
temps[0]="#0044FF";
temps[101]="#0032FF";
temps[102]="#0022FF";
temps[103]="#0012FF";
temps[104]="#0002FF";
temps[105]="#0000FF";
temps[106]="#0100FF";
temps[107]="#0200FF";
temps[108]="#0300FF";
temps[109]="#0400FF";
temps[110]="#0500FF";
temps[111]="#0600FF";

i3status | (read line && echo "$line" && read line && 
    echo "$line" && read line && echo "$line" && while :
do
    read line
    weather=$(head -n 1 ~/.weather.cache)
    color="#FF0000"
    if [ "${weather:0:2}" = "<!" ]; then
        weather="Not Available now"
    elif [ "${weather:0:2}" = "<h" ]; then
        weather="Not Available now"
    elif [ "${weather:0:16}" = "Unknown location" ]; then
        weather="Unknown location"
    else 
        end=${weather: -5}
        temp=${end:0:3}
        if [ "$temp" -lt 0 ]; then
            temp=${temp:1} 
            temp=$(( temp + 100 )) 
        elif [ "$temp" -gt 35 ]; then
            temp=35
            # Send help
        fi

        
        color="${temps[$temp]}"
    fi
    nordvpn_output=$(nordvpn status | cat -v | head -1 | sed -e 's/\^M-^M  ^M//g' )
    if [ "${nordvpn_output}" = "Status: Connected" ]; then
        vpncolor="#00FF00"
        vpnstatus="🥸"
        # Disguised Face Emoji
    elif [ "${nordvpn_output}" = "A new version of NordVPN is available! Please update the application." ]; then
        nordvpn_output=$(nordvpn status | cat -v | head -2 | tail -1 | sed -e 's/\^M-^M  ^M//g' )
        if [ "${nordvpn_output}" = "Status: Connected" ]; then
            vpncolor="#B58900"
            vpnstatus="🥴" 
            # Woozy Face Emoji
        elif [ "${nordvpn_output}" = "Status: Disconnected" ]; then
            vpncolor="#FF0000"
            vpnstatus="📢"
            # Loudspeaker Emoji
        else
            vpncolor="#FF0000"
        fi
    elif [ "${nordvpn_output}" = "Status: Disconnected" ]; then
        vpncolor="#FF0000"
        vpnstatus="📢"
        # Loudspeaker Emoji
    elif [[ "$nordvpn_output" == *\/* ]] || [[ "$nordvpn_output" == *\\* ]]; then
        vpnstatus="Somethings fucky"
        vpncolor="#FF0000"
    else
        vpncolor="#FF0000"
    fi

    #boulderstatus=$(curl -s <Capacity of my local blouder hall, so I could find out, how full it is there, coronatimes and all>)
    #if [ "${boulderstatus}" = "über 50" ] || [ "${boulderstatus}" -gt "35" ]; then
    #    boulderstatus=""
    #    bouldercolor="#00FF00"
    #    boulderemoji="🧗‍♂️"
    #elif [ "${boulderstatus}" -gt "10" ]; then
    #    bouldercolor="#FFA000"
    #    boulderemoji="🧗‍♂️"
    #else
    #    bouldercolor="#FF0000"
    #    boulderemoji="👎"
    #fi

    spinloc=$(((spinloc + 1) % ${#spin}))
    spinner=${spin:$spinloc:1}
    spinnercolor="#00FF00"

    #isp="$(curl -s https://ipinfo.io/org | cut -d' ' -f2- )"
    #TODO oops, they have rate limits

    #boulderstuff="${boulderemoji}${boulderstatus}"
    vpnstatus="${vpnstatus}" # ${isp}"

    #echo ",[{\"full_text\":\"$boulderstuff\",\"color\":\"$bouldercolor\" },{\"full_text\":\"$vpnstatus\",\"color\":\"$vpncolor\" },{\"full_text\":\"${weather}\",\"color\":\"$color\" },${line#,\[}" || exit 1
    echo ",[{\"full_text\":\"$vpnstatus\",\"color\":\"$vpncolor\"},{\"full_text\":\"${weather}\",\"color\":\"$color\" },{\"full_text\":\"$spinner\",\"color\":\"$spinnercolor\" },${line#,\[}" || exit 1

done)

