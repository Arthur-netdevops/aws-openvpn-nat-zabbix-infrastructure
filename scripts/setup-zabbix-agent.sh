#!/bin/bash
# ============================================================
# Script : setup-zabbix-agent.sh
# Auteur : Arthur-Netdevops
# Description : Installation Zabbix Agent sur instance Debian
# Usage : sudo bash setup-zabbix-agent.sh <IP_ZABBIX_SERVER> <HOSTNAME>
# Exemple : sudo bash setup-zabbix-agent.sh 10.0.1.10 debian-autres-services
# ============================================================

set -e

ZABBIX_SERVER=${1:-"10.0.1.10"}
HOSTNAME=${2:-"debian-instance"}

echo "======================================"
echo "  Installation Zabbix Agent"
echo "  Serveur : $ZABBIX_SERVER"
echo "  Hostname : $HOSTNAME"
echo "======================================"

echo "[1/3] Installation..."
apt update && apt install -y zabbix-agent

echo "[2/3] Configuration..."
sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname=.*/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf

echo "[3/3] Démarrage du service..."
systemctl enable zabbix-agent
systemctl restart zabbix-agent
systemctl status zabbix-agent

echo "======================================"
echo "  Zabbix Agent installé et actif !"
echo "  N'oublie pas d'ajouter cet hôte"
echo "  dans l'interface Zabbix Web."
echo "======================================"
