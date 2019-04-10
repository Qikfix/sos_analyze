#!/bin/bash

>executed_commands.txt
cat ../sos_analyze.sh \
		| grep -E '(log_tee "## |log_cmd )' \
		| cut -d " " -f4- \
		| while read line; do echo $line; done >>executed_commands.txt

sed -i 's/^"//g' executed_commands.txt
sed -i 's/"$//g' executed_commands.txt
sed -i 's/^##/\n##/g' executed_commands.txt
