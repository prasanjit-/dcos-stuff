#!/bin/bash
# This bash script installs all pre-requisites for installing Mesosphere DCOS Cluster in Advanced mode for CentOS/Redhat Linux

sudo systemctl stop firewalld 
sudo systemctl disable firewalld 
sudo yum install -y tar xz unzip curl ipset  wget
cd /etc/yum.repos.d/
yum update -y 
wget https://download.docker.com/linux/centos/docker-ce.repo
yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.55-1.el7.noarch.rpm 
yum install docker-ce -y
sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config 
systemctl start docker 
systemctl enable docker 
docker pull nginx 
ntptime 
timedatectl 
sudo groupadd nogroup 
sudo groupadd docker 
sudo localectl set-locale LANG=en_US.utf8
sed -e '/wheel/ s/^#*/#/' -i /etc/sudoers
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers   
sudo reboot
