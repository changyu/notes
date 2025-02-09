#!/bin/bash

RHV_HOST="rhv-host"
VERGEIO_HOST="vergeio-host"
VM_NAME="test-vm"
RHV_DISK_PATH="/rhv/mnt/iso/${VM_NAME}.qcow2"
LOCAL_DISK="/tmp/${VM_NAME}.raw"
VERGEIO_DISK_PATH="/var/lib/vergeio/vms/${VM_NAME}.raw"

# Shutdown VM
ssh root@$RHV_HOST "virsh shutdown $VM_NAME"

# Convert to RAW
ssh root@$RHV_HOST "qemu-img convert -p -O raw $RHV_DISK_PATH $LOCAL_DISK"

# Transfer to VergeIO
rsync -avh --progress $LOCAL_DISK vergeio-user@$VERGEIO_HOST:$VERGEIO_DISK_PATH

# Create VM in VergeIO
ssh vergeio-user@$VERGEIO_HOST "vergeio-cli vm create --name '$VM_NAME' --cpu 4 --ram 8192 --disk $VERGEIO_DISK_PATH --network 'default'"

# Start VM
ssh vergeio-user@$VERGEIO_HOST "vergeio-cli vm start --name '$VM_NAME'"

echo "Migration of $VM_NAME completed successfully!"
