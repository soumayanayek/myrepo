#!/usr/bin/env bash

#set -x


NETWORK="Test_Network1"
IMAGE="centos-7"
IMAGE_WIN=""
SECURITY_GROUP="db3d0a1f-f8a3-4685-8644-d0f27bf71dea"
FLAVOR="m1.medium"
FLAVOR_1=""
KEY_NAME="test1"
RC_FILE_SOURCE="/home/ubuntu/newRcadminopenrc2"

#INP_1=$1
#INP_2=$2
# Check for script parameter
#if [ "$1" == "" ] || [ "$2" == "" ]||[ "$3" == "" ]
#if [ "$1" == "" ]
#   then
#        echo "Usage : $0 <no of instance need to create>"
#        echo " If certificate is not provided it will add --insecure parameter"
#        exit 100
#
#fi
create_linux() 
{
echo $1
#source $RC_FILE_SOURCE
#i=1;
#while [[ i -le $1 ]] ;
#do
#  echo "#################################################"
#  echo "Creating server instance-$i on openstack"
  #touch allvmcreation.log
  #ST=`date +"%T"`
  #openstack server create --image $IMAGE  --flavor $FLAVOR --security-group  $SECURITY_GROUP --key-name $KEY_NAME --network $NETWORK --wait instance-$i >> allvmcreation.log
  #STATUS=$?
  #ET=`date +"%T"`
  #echo "START TIME=$ST ----- END TIME=$ET"
  #if [ "$STATUS" -ne 0 ]; then
  #    echo "SOMETHING WENT WRONG SERVER CREATION STATUS IS NOT 0"
  #    break
  #fi
#  i=$((i+1));
#done;
}

create_windows()
{
echo $1
#i=1;
#while [[ i -le $2 ]] ;
#do
#  echo "#################################################"
#  echo "Creating server instance-$i on openstack"
#  touch allvmcreation.log
#  ST=`date +"%T"`
#  openstack server create --image $IMAGE_WIN  --flavor $FLAVOR_1 --security-group  $SECURITY_GROUP --key-name $KEY_NAME --network $NETWORK --wait instance-$i >> allvmcreation1.log
#  STATUS=$?
#  ET=`date +"%T"`
#  echo "START TIME=$ST ----- END TIME=$ET"
#  if [ "$STATUS" -ne 0 ]; then
#      echo "SOMETHING WENT WRONG SERVER CREATION STATUS IS NOT 0"
#      break
#  fi
#  i=$((i+1));
#done;
}

create_linux $1
create_windows $2
