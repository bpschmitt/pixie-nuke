#!/bin/bash

OVERRIDE_NAMESPACE=$1
NAMESPACES="pl newrelic olm px-operator"

if [[ $OVERRIDE_NAMESPACE != "" ]]; then
    NAMESPACES="$OVERRIDE_NAMESPACE pl olm px-operator"
fi

for i in $NAMESPACES
do
    if [[ $i == "olm" ]]; then
        echo -e "BE CAREFUL - The olm namespace is used by other components in an OpenShift cluster."
    fi

    echo -e "Do you want to delete the $i namespace? (Y/N): "
    read ANSWER

    if [[ $ANSWER =~ (Y|y) ]]; then
        echo -e "Deleting $i namespace. This may take a few minutes...\n"
        echo -e "kubectl delete ns $i\n\n"
        #kubectl delete ns $i
    else
        echo -e "Skipping $i namespace.\n"
    fi
done

echo -e "Deleting clusterroles and clusterrolebindings...\n"
for i in $(kubectl get clusterrole | egrep 'viziers.px.dev|pixie-operator|newrelic-bundle|olm-operators|global-operators' | awk '{print $1}')
do
    echo "kubectl delete clusterrole $i"
done

for i in $(kubectl get clusterrolebinding | egrep 'viziers.px.dev|pixie-operator|newrelic-bundle|olm-operators|global-operators' | awk '{print $1}')
do
    echo "kubectl delete clusterrolebinding $i"
done

exit 0