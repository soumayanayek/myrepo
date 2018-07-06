#!/usr/bin/env bash

#set -x


NETWORK="fc6dbf9d-a6cb-4076-8d49-f95f2ff05967"
IMAGE_1="xenial"
IMAGE_2="mfbaseline-winsrvr2012R2-v1.0-S94-mr-opn-os-20180607"
SECURITY_GROUP="d8a892a7-41a5-4d32-8b46-313391a35e67"
#SECURITY_GROUP="db3d0a1f-f8a3-4685-8644-d0f27bf71dea"
FLAVOR="m1.med"
FLAVOR_1="c4aab934-ff4c-4f76-b3e6-ec2571557c0d"
KEY_NAME="NewKey"
RC_FILE_SOURCE="/home/ubuntu/script_workspace/cloud2openrc.sh"
#INP_1=$1
#INP_2=$2
# Check for script parameter
#if [ "$1" == "" ] || [ "$2" == "" ]||[ "$3" == "" ]
if [ "$1" == "" ]
   then
        echo "Usage : $0 <no of instance need to create>"
        echo " If certificate is not provided it will add --insecure parameter"
        exit 100
fi

create_linux() 
{
source $RC_FILE_SOURCE
i=1;
while [[ i -le $1 ]] ;
do
  echo "#################################################"
  AST=`date +"%T"`
  echo "Creating server instance_S1-$i on openstack"
  touch allvmcreation.log
  ST=`date +"%T"`
  openstack server create --image $IMAGE_1  --flavor $FLAVOR --security-group  $SECURITY_GROUP --key-name $KEY_NAME --network $NETWORK --wait instance_S1-$i >> allvmcreation.log
  STATUS=$?
  ET=`date +"%T"`
  echo "START TIME=$ST ----- END TIME=$ET"
  if [ "$STATUS" -ne 0 ]; then
      echo "SOMETHING WENT WRONG SERVER CREATION STATUS IS NOT 0"
      break
  fi
  i=$((i+1));
done;
AET=`date +"%T"`
echo "Actual Start Time = $AST ##### Actual end time = $AET" > file_$(date +"%T").txt
}

create_windows()
{
i=1;
while [[ i -le $1 ]] ;
do
  AST=`date +"%T"`
  echo "#################################################"
  echo "Creating server instance-S2-$i on openstack"
  touch allvmcreation.log
  ST=`date +"%T"`
  openstack server create --image $IMAGE_2  --flavor $FLAVOR_1 --security-group  $SECURITY_GROUP --key-name $KEY_NAME --network $NETWORK --wait instance_S2-$i >> allvmcreation1.log
  STATUS=$?
  ET=`date +"%T"`
  echo "START TIME=$ST ----- END TIME=$ET"
  if [ "$STATUS" -ne 0 ]; then
      echo "SOMETHING WENT WRONG SERVER CREATION STATUS IS NOT 0"
      break
  fi
  i=$((i+1));
done;
AET=`date +"%T"`
echo "Actual Start Time = $AST ##### Actual end time = $AET" > file_$(date +"%T").txt
}

echo "Creating 1st set of $1 instance/instances"
create_linux $1
if  [ "$1" != "" ]
  then
    echo "Creating 2nd set of $2 instance/instances"
    create_windows $2
fi
