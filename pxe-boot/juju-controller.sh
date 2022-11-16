#!/bin/bash
VM_NAMES=(
juju-controller001
)

for VM_NAME in ${VM_NAMES[@]}; do
  qemu-img create -f qcow2 /data/vms/$VM_NAME-vda.qcow2 40G >/dev/null
  virt-install --virt-type kvm \
    --name $VM_NAME \
    --os-type=linux --os-variant=ubuntu20.04 \
    --ram=4096 --vcpus=2 \
    --cpu host-passthrough,cache.mode=passthrough \
    --pxe --graphics vnc \
    --boot network,hd \
    --network bridge=virbr2 \
    --disk path=/data/vms/$VM_NAME-vda.qcow2,bus=scsi \
    --noautoconsole --noreboot >/dev/null && virsh destroy $VM_NAME >/dev/null

  UUID=$(virsh dumpxml $VM_NAME | grep uuid | perl -lape 's/\s\s.\w+.(.*)<.*/$1/gm')
  MAC1=$(virsh dumpxml $VM_NAME | grep "mac address" | perl -lape 's/.*<\w+\s\w+..(.*).../$1/gm' | awk 'NR==1')
    echo
    echo "$VM_NAME UUID: $UUID"
    echo "$VM_NAME MAC1: $MAC1"
    echo
done
