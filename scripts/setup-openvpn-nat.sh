#!/bin/bash
# ============================================================
# Script : setup-openvpn-nat.sh
# Auteur : Arthur-Netdevops
# Description : Installation et configuration OpenVPN + NAT
#               sur EC2 Debian (subnet public)
# Usage : sudo bash setup-openvpn-nat.sh
# ============================================================

set -e

INTERFACE="ens5"
VPN_NETWORK="172.16.10.0"
VPN_MASK="255.255.255.0"
PRIVATE_SUBNET="10.0.1.0/24"

echo "======================================"
echo "  Setup OpenVPN + NAT Instance"
echo "======================================"

echo "[1/5] Mise à jour du système..."
apt update && apt upgrade -y

echo "[2/5] Installation OpenVPN + EasyRSA..."
apt install -y openvpn easy-rsa iptables-persistent

echo "[3/5] Activation IP Forwarding..."
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

echo "[4/5] Configuration iptables NAT..."
iptables -t nat -A POSTROUTING -s 172.16.10.0/24 -o $INTERFACE -j MASQUERADE
iptables -t nat -A POSTROUTING -s $PRIVATE_SUBNET -o $INTERFACE -j MASQUERADE
iptables -A FORWARD -i tun0 -o $INTERFACE -j ACCEPT
iptables -A FORWARD -i $INTERFACE -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $INTERFACE -o $INTERFACE -s $PRIVATE_SUBNET -j ACCEPT
netfilter-persistent save

echo "[5/5] Initialisation PKI EasyRSA..."
make-cadir /root/easy-rsa
echo ""
echo "======================================"
echo "  Installation de base terminée !"
echo "  Etapes suivantes (manuelles) :"
echo "  1. cd /root/easy-rsa"
echo "  2. ./easyrsa init-pki"
echo "  3. ./easyrsa build-ca nopass"
echo "  4. ./easyrsa gen-req server nopass"
echo "  5. ./easyrsa sign-req server server"
echo "  6. ./easyrsa gen-dh"
echo "  7. ./easyrsa gen-req client1 nopass"
echo "  8. ./easyrsa sign-req client client1"
echo "  Voir README.md pour la suite."
echo "======================================"
