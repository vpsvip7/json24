#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Uso: $0 <interfaz> <tasa_descarga (ej: 1mbit)> <tasa_subida (ej: 1mbit)>"
    exit 1
fi

INTERFACE="$1"
DOWN_RATE="$2"
UP_RATE="$3"

# Limpiar reglas existentes
sudo tc qdisc del dev $INTERFACE root 2>/dev/null
sudo tc qdisc del dev $INTERFACE handle ffff: ingress 2>/dev/null

# Limitar descarga
sudo tc qdisc add dev $INTERFACE root handle 1: htb default 12
sudo tc class add dev $INTERFACE parent 1: classid 1:12 htb rate $DOWN_RATE

# Limitar subida (usando IFB)
sudo modprobe ifb
sudo ip link set dev ifb0 up
sudo tc qdisc add dev $INTERFACE ingress
sudo tc filter add dev $INTERFACE parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add dev ifb0 root handle 1: htb
sudo tc class add dev ifb0 parent 1: classid 1:12 htb rate $UP_RATE