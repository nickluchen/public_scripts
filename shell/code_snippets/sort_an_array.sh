#!/bin/bash

array=(
"/Sync"
"/Groovy"
"/Multimedia"
"/Gallery"
"/Database"
)

IFS=$'\n' sorted=($(sort <<<"${array[*]}"))
unset IFS

for i in ${sorted[*]}; do
  echo $i
done
