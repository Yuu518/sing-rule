#!/bin/bash

mkdir -p geoip
./mosdns v2dat unpack-ip -o ./geoip/ geoip.dat
list=($(ls ./geoip | sed 's/geoip_//g' | sed 's/\.txt//g'))
for ((i = 0; i < ${#list[@]}; i++)); do
	#	echo "${list[i]}"
	mv ./geoip/geoip_${list[i]}.txt ./geoip/${list[i]}.list
	echo "payload:" >./geoip/${list[i]}.yaml
	cat ./geoip/${list[i]}.list | sed 's/^/- "/g' | sed 's/$/"/g' >>./geoip/${list[i]}.yaml
done

mkdir -p geosite
./mosdns v2dat unpack-domain -o ./geosite/ geosite.dat
list=($(ls ./geosite | sed 's/geosite_//g' | sed 's/\.txt//g'))
for ((i = 0; i < ${#list[@]}; i++)); do
	#	echo "${list[i]}"
	mv ./geosite/geosite_${list[i]}.txt ./geosite/${list[i]}.list
	sed -i '/^#/d' geosite/${list[i]}.list
	sed -i '/^keyword:/d' geosite/${list[i]}.list
	sed -i '/^regexp:/d' geosite/${list[i]}.list
	sed -i 's/^/+./g' ./geosite/${list[i]}.list
	sed -i 's/+.full://g' ./geosite/${list[i]}.list
	sed -i 's/+.domain:/+./g' ./geosite/${list[i]}.list
	echo "payload:" >./geosite/${list[i]}.yaml
	cat ./geosite/${list[i]}.list | sed 's/^/- "/g' | sed 's/$/"/g' >>./geosite/${list[i]}.yaml
done

#mkdir -p mixed
#for file in $(find geoip -type f | grep -v srs | awk -F "/" '{print $NF}'); do
#	if [ -n "$(find geosite -type f -iname "$file")" ]; then
#		file=$(find ./geosite -type f -iname "$file" | awk -F"/" '{print $NF}' | sed 's/\.json//g')
#		head -n -3 ./geoip/${file}.json >./mixed/${file}.json
#		sed -i 's/]/],/g' ./mixed/${file}.json
#		tail -n +5 ./geosite/${file}.json >>./mixed/${file}.json
#		./sing-box rule-set compile ./mixed/${file}.json -o ./mixed/${file}.srs
#	fi
#done
