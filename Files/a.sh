#!/bin/bash
red=`tput setab 1`
white=`tput setaf 7`
green=`tput setab 2`
reset=`tput sgr0`
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
IFS='/' read -ra ADDRX <<< "$SCRIPTPATH"
ptd=$HOME
while read USER; do IFS=':' read -ra ADDRY <<< "$USER"; done < $ptd/AutoApkConfig.txt
noname="${ADDRY[${#ADDRY[@]} - 1]}"
echo "AutoName for Signing is set to $noname"
read -e -p "Function[d, b, s, p, AutoName{0/1}, help]: " fun
if [ "$fun" == "help" ]; then
  printf "Command List:\nd - Decompiles an APK [Provide any APK]\nb - Builds an APK [Provide Decompiled Folder]\ns - Signs an APK [Provide any APK]\np - Builds & Signs and APK [Provide Decompiled Folder]\nAutoName - Option to Automatically get the perfect name for your signed apk, edit its value from $HOME/AutoApkConfig.txt\nUsage: Autoname 1 or Autoname 0\n!NOTE: Only works if your game name is at the end\nExample - com.mycompany.gamename, signed apk will be 'gamename'.apk\nif its com.mycompany.gamename.extra then your output apk will be named 'extra.apk'\n"
  sleep 3
  a.sh
elif [ "$fun" == "AutoName 0" ]; then
  rm $ptd/AutoApkConfig.txt
  echo 'AutoName :0' >"$ptd/AutoApkConfig.txt"
  sleep 1
  a.sh
elif [ "$fun" == "AutoName 1" ]; then
  rm $ptd/AutoApkConfig.txt
  echo 'AutoName :1' >"$ptd/AutoApkConfig.txt"
  sleep 1
  a.sh
else
  read -e -p "File: " file
  if [ $fun == "s" ] || [ $fun == "b" ] || [ $fun == "d" ] || [ $fun == "p" ] ; then
    if [ $fun == "s" ]; then
      if [ "$noname" != "1" ]; then
        read -e -p "OutputName[No need to add .apk]: " name
      else
        IFS='.' read -ra ADDRXO <<< "$file"
        name="${ADDRXO[${#ADDRXO[@]} - 2]}"
      fi
      ex2=".apk"
      echo "${green}${white}Now Signing!${reset}"
      java -jar signapk.jar testkey.x509.pem testkey.pk8 $file $name$ex2
      echo "${green}${white}Signing Successfull${reset}"
    elif [ $fun == "d" ]; then
      IFS='/' read -ra ADDR <<< "$file"
      tbr=".apk"
      dir="/${ADDR[1]}/${ADDR[2]}/${ADDR[${#ADDR[@]} - 1]}"
      fdir="${dir//$tbr/}"
      if [ -d "$fdir" ]; then
        fun="d -f"
      fi
      if [ "$fun" == "d" ]; then
        echo "${green}${white}Now Decompiling!${reset}"
      fi
      if [ "$fun" == "d -f" ]; then
        echo "${green}${white}Now Force Decompiling!${reset}"
      fi
      apktool $fun $file
      if [ "$fun" == "d" ]; then
        echo "${green}${white}Decompiling Successfull!${reset}"
      fi
      if [ "$fun" == "d -f" ]; then
        echo "${green}${white}Force Decompiling Successfull!${reset}"
      fi
    elif [ $fun == "p" ]; then
      dist="/dist/"
      IFS='/' read -ra ADDR <<< "$file"
      filename=${ADDR[${#ADDR[@]} - 1]}
      ext=".apk"
      final=$file$dist$filename$ext
      if [ "$noname" != "1" ]; then
        read -e -p "OutputName[No need to add .apk]: " name2
      else
        IFS='.' read -ra ADDRO <<< "$filename"
        name2=${ADDRO[${#ADDRO[@]} - 1]}
      fi
      echo "${green}${white}Now Building!${reset}"
      apktool b $file
      echo "${green}${white}Building Successfull!${reset}"
      echo "${green}${white}Now Signing!${reset}"
      java -jar signapk.jar testkey.x509.pem testkey.pk8 $final $name2$ext
      echo "${green}${white}Signing Successfull!${reset}"
    else

        echo "${green}${white}Now Building!${reset}"

        apktool b $file

        echo "${green}${white}Building Successfull!${reset}"


    fi
  else
    echo "${red}${white}Invalid Function, Choose between b, d, s, p, AutoName{0/1}, help${reset}"
    a.sh
  fi
fi
