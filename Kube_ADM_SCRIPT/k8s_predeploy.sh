#!/bin/bash
#set -x

# Check for script parameter
if [ "$1" != "-i" ] || [ "$2" == "" ]||[ "$3" == "" ]
   then
        echo "Usage : $0 -i <name of API & POD network interface> <IP_ADD> <NET_MASK>"
        echo "If CIDR is not given , default CIDR will be aplied as /24"
        exit 100
fi

# ensure running as root
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
fi

# Turnoff swap memory and enable sysctl nat rule

swap_blkid=`blkid | grep swap | cut -d'"' -f2`
fstab_swap_status=`grep $swap_blkid /etc/fstab`

if [[ $fstab_swap_status =~ ^# ]];
   then
     echo "Swap entry in fstab is already disabled, turning swapoff from proc"
     swapoff -a
else
    echo "Disabling swap entry in fstab , turning swapoff from proc"
    sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    swapoff -a
fi

# Custom Variables
PATH_TO_IFACE_CONFIG="/etc/network/interfaces"
HOSTNAME=`cat k8s_pre_d_config | grep $3 | cut -d"=" -f1`
NODE_IP=$3
NODE_MASK=$4
NODE_INTF=$2
ETC_HOSTS=/etc/hosts
KUBEMASTER_IP=`/sbin/ifconfig $NODE_INTF | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# Change the hostname based on inputs
change_Hostname(){

echo "Changing hostname"
checkhostname=`hostname`

if [ "$HOSTNAME" !=  "$checkhostname" ];
    then
	    hostnamectl set-hostname $HOSTNAME
	else
	    echo "Hostname is already set"
 fi
}

#Configure Network Interface
conf_interface(){
cat <<EOF >> $PATH_TO_IFACE_CONFIG

# k8s node POD network
auto $NODE_INTF
iface $NODE_INTF inet static
address $NODE_IP
netmask $NODE_MASK

EOF
service networking restart
}

#Populate Host entries
echo "Generating Host entries"
add_host_entries(){
filename='k8s_pre_d_config'
echo "Adding Host entries based on data available on k8s_pre_d_config file"
while read -r p; do
    HOSTNAME=`echo $p | cut -d"=" -f1`
    IP_ADD=`echo $p | cut -d"=" -f2`
    HOSTS_LINE="$IP_ADD\t$HOSTNAME"
    if [ -n "$(grep $IP_ADD /etc/hosts)" ]
        then
            echo "$IP_ADD already exists : $(grep $HOSTNAME $ETC_HOSTS)"
        else
            echo "Adding $HOSTNAME to your $ETC_HOSTS";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts";

            if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                then
                    echo "$HOSTNAME was added succesfully \n $(grep $HOSTNAME /etc/hosts)";
                else
                    echo "Failed to Add $HOSTNAME, Try again!";
            fi
    fi
done < $filename

}

# Assign IP to network interface
assign_ip(){
echo "Assigning IP address to unnumbered interface"

if `! grep -Eq "$NODE_INTF" $PATH_TO_IFACE_CONFIG`;
   then

    #Adding Static IP to KubeMaster Node
    cp $PATH_TO_IFACE_CONFIG /etc/network/interfaces.bkp
    conf_interface
else

    echo "Network interface you mentioned in $0 -i $2 is present in $PATH_TO_IFACE_CONFIG file"

fi
}


assign_ip

change_Hostname

add_host_entries
