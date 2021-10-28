
#!/bin/bash

set +e

if [[ -z ${1} ]]; then
        echo "Usage: $0 <batches>"
        exit 1
fi

COUNT=$((${1}-1))

i=0
while [ ${i} -le ${COUNT} ]; do
        group=${RANDOM}.example.org

        sed "s/%GROUP%/${group}/g" 100-crds.yaml | kubectl apply -f -

        echo
        echo "Iteration ${i} complete"
        echo

        sleep 60
        i=$((i+1))
done
