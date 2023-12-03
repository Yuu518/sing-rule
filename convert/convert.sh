#!/bin/bash

mkdir -p geoip
./mosdns v2dat unpack-ip -o ./geoip/ geoip.dat
list=($(ls ./geoip | sed 's/geoip_//g' | sed 's/\.txt//g'))
for ((i = 0; i < ${#list[@]}; i++)); do
	sed -i 's/^/        "/g' ./geoip/geoip_${list[i]}.txt
	sed -i 's/$/",/g' ./geoip/geoip_${list[i]}.txt
	sed -i '1s/^/{\n  "version": 1,\n  "rules": [\n    {\n      "ip_cidr": [\n/g' ./geoip/geoip_${list[i]}.txt
	sed -i '$ s/,$/\n      ]\n    }\n  ]\n}/g' ./geoip/geoip_${list[i]}.txt
	mv ./geoip/geoip_${list[i]}.txt ./geoip/${list[i]}.json
	./sing-box rule-set compile "./geoip/${list[i]}.json" -o ./geoip/${list[i]}.srs
done

list=($(./sing-box geosite list | sed 's/ (.*)$//g'))
mkdir -p geosite
for ((i = 0; i < ${#list[@]}; i++)); do
	./sing-box geosite export ${list[i]} -o ./geosite/${list[i]}.json
	./sing-box rule-set compile ./geosite/${list[i]}.json -o ./geosite/${list[i]}.srs
done

mkdir -p mixed
for file in $(find geoip -type f | grep -v srs | awk -F "/" '{print $NF}'); do
	if [ -n "$(find geosite -type f -iname "$file")" ]; then
		file=$(find ./geosite -type f -iname "$file" | awk -F"/" '{print $NF}' | sed 's/\.json//g')
		head -n -3 ./geoip/${file}.json >./mixed/${file}.json
		sed -i 's/]/],/g' ./mixed/${file}.json
		tail -n +5 ./geosite/${file}.json >>./mixed/${file}.json
		./sing-box rule-set compile ./mixed/${file}.json -o ./mixed/${file}.srs
	fi
done
