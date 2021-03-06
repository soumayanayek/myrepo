#!/bin/bash


# APT package
echo "Running apt update"
apt-get update
echo "Satisfying few dependencies"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
# Adding gpg key
echo "Adding GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
if [ "$?" -ne 0 ];
   then
      exit 1
fi
echo "Adding docker repo"
add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
if [ "$?" -ne 0 ];
   then
      exit 1
fi
echo "Running APT update"
apt-get update
echo "Installing docker-ce"
apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
echo "Installing dependencies"
apt-get update && apt-get install -y apt-transport-https curl
echo "Adding gpg-key"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "Adding k8s URL to source list"
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
echo "Updating apt"
apt-get update
echo "Installing Kubeadm,kubelet,kubectl"
apt-get install -y kubelet kubeadm kubectl


siring2add="--cgroup-driver=cgroupfs"
file2edit="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
string2find=`grep "KUBELET_KUBECONFIG_ARGS=" $file2edit | cut -d'"' -f2`
# Change cgroup-driver
if [ -n "$(grep "cgroup-driver" $file2edit)" ];
    then
       echo "cgroup-driver info present .. changing value to cgroupfs"
       sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" $file2edit
       systemctl daemon-reload
       systemctl restart kubelet
else
       echo "cgroup-driver is not present .. Adding cgroup-driver info"
       sed -i "s|$string2find|$string2find $siring2add|g" $file2edit
       systemctl daemon-reload
       systemctl restart kubelet
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

