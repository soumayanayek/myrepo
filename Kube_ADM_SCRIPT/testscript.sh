echo "Generating Host entries"
ETC_HOSTS="hosts"
filename='k8s_pre_d_config'
echo "Adding Host entries based on data available on k8s_pre_d_config file"
while read -r p; do
    HOSTNAME=`echo $p | cut -d"=" -f1`
    IP_ADD=`echo $p | cut -d"=" -f2`
    HOSTS_LINE="$IP_ADD\t$HOSTNAME"
    echo $HOSTNAME\t$IP_ADD
    echo "################"
    if [ -n "$(grep $IP_ADD hosts)" ]
        then
            echo "$IP_ADD already exists : $(grep $HOSTNAME $ETC_HOSTS)"
        else
            echo "Adding $HOSTNAME to your $ETC_HOSTS";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> hosts";

            if [ -n "$(grep $HOSTNAME hosts)" ]
                then
                    echo "$HOSTNAME was added succesfully \n $(grep $HOSTNAME hosts)";
                else
                    echo "Failed to Add $HOSTNAME, Try again!";
            fi
    fi
done < $filename

