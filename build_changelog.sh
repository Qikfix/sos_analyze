#!/bin/bash

CHANGE="changelog.log"

> $CHANGE

echo "General Info"																									| tee -a $CHANGE
echo "---"																													| tee -a $CHANGE
git log --oneline | awk '{print  $2}' | grep "\[" | sort | uniq -c | sort -nr | tee -a $CHANGE
echo "---"																													| tee -a $CHANGE
echo																																| tee -a $CHANGE
echo																																| tee -a $CHANGE

for b in $(git log --oneline | awk '{print  $2}' | grep "\[" | sort | uniq -c | sort -nr | awk '{print $2}')
do
  echo - $b																													| tee -a $CHANGE
  parsed=$(echo $b | sed -e 's/\[/\\[/g' | sed -e 's/\]/\\]/g')
  for x in $(git log --oneline | grep "$parsed" | awk '{print $1}')
  do
    comm_info=$(git log -1 --pretty="%cd | %s" $x)
    echo "  - $comm_info"																						| tee -a $CHANGE
  done
  echo																															| tee -a $CHANGE
  echo																															| tee -a $CHANGE
done
