# Enable macvtap on KVM machines (one liner)
virsh list --name --all | sed '/^$/d' | while read box; do virsh dumpxml $box; done | grep -o "macvtap[0-9\'].*" | cut -d"'" -f 1 | while read iface; do echo $iface && ip link set dev $iface allmulticast on; done
