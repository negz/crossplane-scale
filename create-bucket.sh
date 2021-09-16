#!/bin/bash

set +e

if [[ -z ${1} ]]; then
        echo "Usage: $0 <bucket-count>"
        exit 1
fi

COUNT=$((${1}-1))

i=0
while [ ${i} -le ${COUNT} ]; do
        sed "s/%INT%/${i}/g" bucket.yaml.tmpl | kubectl create -f -
        i=$((i+1))
done