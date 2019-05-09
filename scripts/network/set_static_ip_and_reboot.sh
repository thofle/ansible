#!/bin/bash

# this is made for my little home env and assumes every network adapter is eth0, netmask is 255.255.252.0 and what not


while [ $# -gt 0 ]; do
  case "$1" in
    --dynamic_ip=*)
      dyn_ip="${1#*=}"
      ;;
    --static_ip=*)
      static_ip="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

tfile=$(mktemp /tmp/newip.XXXXXXXXX)
echo "Creating temp file $tfile"

echo "BOOTPROTO=static" > $tfile
echo "IPADDR=$static_ip" >> $tfile
echo "NETMASK=255.255.252.0" >> $tfile
echo "GATEWAY=192.168.0.1" >> $tfile
echo "DNS1=192.168.0.1" >> $tfile
echo "DNS2=1.1.1.1" >> $tfile
echo "DNS3=8.8.4.4" >> $tfile
echo "DEVICE=eth0" >> $tfile

scp $tfile $dyn_ip:/tmp/new_static_ip
ssh $dyn_ip "sudo mv /tmp/new_static_ip /etc/sysconfig/network-scripts/ifcfg-eth0"
ssh $dyn_ip "sudo chown root:root /etc/sysconfig/network-scripts/ifcfg-eth0"
ssh $dyn_ip "sudo reboot now"
rm $tfile
