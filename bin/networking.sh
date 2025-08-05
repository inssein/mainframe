CHOSEN_HOST_MACVLAN_IP="192.168.0.228"
PHYSICAL_INTERFACE="enp11s0"
VM_IP="192.168.0.74"

sudo ip link add macvlan-host link $PHYSICAL_INTERFACE type macvlan mode bridge
sudo ip addr add ${CHOSEN_HOST_MACVLAN_IP}/32 dev macvlan-host
sudo ip link set macvlan-host up
sudo ip route add ${VM_IP}/32 dev macvlan-host
