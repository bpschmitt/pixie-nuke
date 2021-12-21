#!/bin/bash
#
#
# Description: A simple bash script to cleanup a Pixie and New Relic installation in a Kubernetes cluster.
#      Author: Brad Schmitt
#        Date: 12/21/21
#
#
#

OVERRIDE_NAMESPACE=$1
NAMESPACES="pl newrelic olm px-operator"
CRDS="https://download.newrelic.com/install/kubernetes/pixie/latest/px.dev_viziers.yaml https://download.newrelic.com/install/kubernetes/pixie/latest/olm_crd.yaml"

if [[ $OVERRIDE_NAMESPACE != "" ]]; then
    NAMESPACES="$OVERRIDE_NAMESPACE pl olm px-operator"
fi

for i in $NAMESPACES
do
    if [[ $i == "olm" ]]; then
        echo -e "CAUTION: IF THIS IS OPENSHIFT, DO NOT DELETE THE OLM NAMESPACE."
    fi

    echo -e "Do you want to delete the $i namespace? (Y/N): "
    read ANSWER

    if [[ $ANSWER =~ (Y|y) ]]; then
        echo -e "Deleting $i namespace. This may take a few minutes...\n"
        #echo -e "kubectl delete ns $i\n\n"
        kubectl delete ns $i
    else
        echo -e "Skipping $i namespace.\n"
    fi
done

echo -e "Deleting clusterroles and clusterrolebindings...\n"
for i in $(kubectl get clusterrole | egrep 'viziers.px.dev|pixie-operator|newrelic-bundle|olm-operators|global-operators' | awk '{print $1}')
do
    #echo "kubectl delete clusterrole $i"
    kubectl delete clusterrole $i
done

for i in $(kubectl get clusterrolebinding | egrep 'viziers.px.dev|pixie-operator|newrelic-bundle|olm-operators|global-operators' | awk '{print $1}')
do
    #echo "kubectl delete clusterrolebinding $i"
    kubectl delete clusterrolebinding $i
done

echo "Deleting Pixie CRDs..."
for i in $CRDS
do
    kubectl delete -f $i
done

exit 0