#!/bin/sh

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum update -y
sudo yum install -y openvpn easy-rsa
sudo mkdir /etc/openvpn/easy-rsa
sudo cp -Rv /usr/share/easy-rsa/3.0.7/* /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
sudo ./easyrsa init-pki
sudo ./easyrsa build-ca
sudo ./easyrsa gen-dh
sudo ./easyrsa gen-req server
sudo ./easyrsa sign-req server server
cd /etc/openvpn
sudo openvpn --genkey --secret ta.key
sudo mkdir /etc/openvpn/easy-rsa/private/
sudo mv /etc/openvpn/ta.key /etc/openvpn/easy-rsa/private/ta.key
sudo cp /usr/share/doc/openvpn-2.4.9/sample/sample-config-files/server.conf /etc/openvpn/
sed -i 's|ca ca.crt|ca /etc/openvpn/easy-rsa/pki/ca.crt|g' /etc/openvpn/server.conf
sed -i 's|cert server.crt|cert /etc/openvpn/easy-rsa/pki/issued/server.crt|g' /etc/openvpn/server.conf
sed -i 's|key server.key|key /etc/openvpn/easy-rsa/pki/private/server.key|g' /etc/openvpn/server.conf
sed -i 's|dh dh2048.pem|dh /etc/openvpn/easy-rsa/pki/dh.pem|g' /etc/openvpn/server.conf
sed -i 's|tls-auth ta.key|tls-auth /etc/openvpn/easy-rsa/private/ta.key|g' /etc/openvpn/server.conf
sudo openvpn /etc/openvpn/server.conf
