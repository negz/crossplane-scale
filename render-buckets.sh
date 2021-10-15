#!/bin/bash

set +e

if [[ -z ${1} ]]; then
        echo "Usage: $0 <bucket-count>"
        exit 1
fi

COUNT=$((${1}-1))

i=0
while [ ${i} -le ${COUNT} ]; do
        name=${RANDOM}
        cat <<EOF
---
apiVersion: test.crossplane.io/v1alpha1
kind: Bucket
metadata:
  name: scale-test-${name}
spec:
  parameters:
    location: USA
  writeConnectionSecretToRef:
    name: scale-test-${name}
EOF
        i=$((i+1))
done