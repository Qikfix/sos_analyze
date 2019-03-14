#!/bin/bash
cat ../sos_analyze.sh \
		| grep -E '("## |&>>|base_dir=|base_foreman=)' \
		| sed -e 's/| tee -a $FOREMAN_REPORT//g' \
		| sed -e 's/&>> $FOREMAN_REPORT//g' \
		| sed -e 's/^  echo //g' \
		| sed -e 's/^  //g' \
		| sed -e 's/\t//g' \
		| sed -e 's/^"##/\n##/g' \
		>executed_commands.txt
