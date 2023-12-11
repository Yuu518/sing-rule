#!/bin/bash

mkdir -p rule_set_ip
./mosdns v2dat unpack-ip -o ./rule_set_ip/ geoip.dat
list=($(ls ./rule_set_ip | sed 's/geoip_//g' | sed 's/\.txt//g'))
for ((i = 0; i < ${#list[@]}; i++)); do
	sed -i 's/^/        "/g' ./rule_set_ip/geoip_${list[i]}.txt
	sed -i 's/$/",/g' ./rule_set_ip/geoip_${list[i]}.txt
	sed -i '1s/^/{\n  "version": 1,\n  "rules": [\n    {\n      "ip_cidr": [\n/g' ./rule_set_ip/geoip_${list[i]}.txt
	sed -i '$ s/,$/\n      ]\n    }\n  ]\n}/g' ./rule_set_ip/geoip_${list[i]}.txt
	mv ./rule_set_ip/geoip_${list[i]}.txt ./rule_set_ip/${list[i]}.json
	./sing-box rule-set compile "./rule_set_ip/${list[i]}.json" -o ./rule_set_ip/${list[i]}.srs
done

list=($(./sing-box geosite list | sed 's/ (.*)$//g'))
mkdir -p rule_set_site
for ((i = 0; i < ${#list[@]}; i++)); do
	./sing-box geosite export ${list[i]} -o ./geosite/${list[i]}.json
	./sing-box rule-set compile ./rule_set_site/${list[i]}.json -o ./rule_set_site/${list[i]}.srs
done

# mkdir -p mixed
# for file in $(find geoip -type f | grep -v srs | awk -F "/" '{print $NF}'); do
# 	if [ -n "$(find geosite -type f -iname "$file")" ]; then
# 		file=$(find ./geosite -type f -iname "$file" | awk -F"/" '{print $NF}' | sed 's/\.json//g')
# 		head -n -3 ./geoip/${file}.json >./mixed/${file}.json
# 		sed -i 's/]/],/g' ./mixed/${file}.json
# 		tail -n +5 ./geosite/${file}.json >>./mixed/${file}.json
# 		./sing-box rule-set compile ./mixed/${file}.json -o ./mixed/${file}.srs
# 	fi
# done
