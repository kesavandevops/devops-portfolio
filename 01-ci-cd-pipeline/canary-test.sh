#!/bin/bash
LB="${1:-ab3df145ab6cd495abcef0cfbcb7b8a8-1164169759.ap-south-1.elb.amazonaws.com}"
N=${2:-50}
blue=0; green=0
for i in $(seq 1 $N); do
  r=$(curl -s "http://$LB/")
  if [[ "$r" == *"BLUE"* ]]; then
    blue=$((blue+1))
  elif [[ "$r" == *"GREEN"* ]]; then
    green=$((green+1))
  fi
done
echo "BLUE: $blue"
echo "GREEN: $green"
