
#!/bin/bash

set +e

if [[ -z ${3} ]]; then
        echo "Usage: $0 <sleep-seconds> <batches> <batch-size>"
        exit 1
fi

SLEEP=${1}
COUNT=$((${2}-1))
SIZE=$((${3}-1))

function batch {
        local j=0
        while [ ${j} -le ${SIZE} ]; do
                sed "s/%GROUP%/${RANDOM}.example.org/g" crd.yaml.tmpl
                j=$((j+1))
        done
}

i=0
while [ ${i} -le ${COUNT} ]; do
        batch | kubectl apply -f -

        echo
        echo "Iteration $((i+1)) complete"
        echo

        sleep ${SLEEP}
        i=$((i+1))
done
