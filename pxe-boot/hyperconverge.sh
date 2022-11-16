#!/bin/bash
VM_NAMES=(
hyperconverge001
hyperconverge002
hyperconverge003
)

for VM_NAME in ${VM_NAMES[@]}; do
  qemu-img create -f qcow2 /data/vms/$VM_NAME-vda.qcow2 100G >/dev/null
  qemu-img create -f qcow2 /data/vms/$VM_NAME-vdb.qcow2 25G >/dev/null
  qemu-img create -f qcow2 /data/vms/$VM_NAME-vdc.qcow2 25G >/dev/null
  qemu-img create -f qcow2 /data/vms/$VM_NAME-vdd.qcow2 25G >/dev/null
  virt-install --virt-type kvm \
    --name $VM_NAME \
    --os-type=linux --os-variant=ubuntu20.04 \
    --ram=16384 --vcpus=6 \
    --cpu host-passthrough,cache.mode=passthrough \
    --pxe --graphics vnc \
    --boot network,hd \
    --network bridge=virbr2 \
    --network bridge=virbr3 \
    --disk path=/data/vms/$VM_NAME-vda.qcow2,bus=scsi \
    --disk path=/data/vms/$VM_NAME-vdb.qcow2,bus=scsi \
    --disk path=/data/vms/$VM_NAME-vdc.qcow2,bus=scsi \
    --disk path=/data/vms/$VM_NAME-vdd.qcow2,bus=scsi \
    --noautoconsole --noreboot >/dev/null && virsh destroy $VM_NAME >/dev/null

  UUID=$(virsh dumpxml $VM_NAME | grep uuid | perl -lape 's/\s\s.\w+.(.*)<.*/$1/gm')
  MAC1=$(virsh dumpxml $VM_NAME | grep "mac address" | perl -lape 's/.*<\w+\s\w+..(.*).../$1/gm' | awk 'NR==1')
    echo
    echo "$VM_NAME UUID: $UUID"
    echo "$VM_NAME MAC1: $MAC1"
    echo
done
