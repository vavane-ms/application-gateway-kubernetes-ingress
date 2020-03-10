GetIngressIPWithRetry() {
    for ((i=1;i<=100;i++));
    do
        publicIP=$(kubectl get $1 -o json | jq -r ".status.loadBalancer.ingress[0].ip")
        if [[ $publicIP != "null" && $publicIP != "" ]]
        then
            echo $publicIP
            exit 0
        fi
        echoerr "Public Ip is null. Will retry again in 1 sec"
        sleep 5
    done

    echoerr "Timed out while waiting to get ingress ip."
    exit -1
}

WaitUntil200() {
    for ((i=1;i<=100;i++));
    do
        statusCode=$(curl -sSI $1 -w "%{http_code}" -o /dev/null)
        if [[ $statusCode == 2* ]]
        then
            exit 0
        fi
        sleep 5
    done

    echoerr "Timed out while waiting for 200 OK from the app gateway"
    exit -1
}

DeleteAGICPod() {
    kubectl delete pods -l app=ingress-azure
}

echoerr() { echo "$@" 1>&2; }