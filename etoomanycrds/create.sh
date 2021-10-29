
#!/bin/bash

set +e

if [[ -z ${2} ]]; then
        echo "Usage: $0 <sleep-seconds> <batches>"
        exit 1
fi

SLEEP=${1}
COUNT=$((${2}-1))

i=0
while [ ${i} -le ${COUNT} ]; do
        group=${RANDOM}.example.org

        sed "s/%GROUP%/${group}/g" 100-crds.yaml | kubectl apply -f -

        echo
        echo "Iteration ${i} complete"
        echo

        sleep ${SLEEP}
        i=$((i+1))
done
