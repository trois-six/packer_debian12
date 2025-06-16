#!/bin/bash -eux

CLEANUP_PAUSE=${CLEANUP_PAUSE:-0}
echo "==> Pausing for ${CLEANUP_PAUSE} seconds..."
sleep ${CLEANUP_PAUSE}

# Cleaning linux packages
CURRENT_KERNEL=$(uname -r)
PURGE=""
VERSIONS=$(ls -f /boot/vmlinuz-* | sed -e "s/[^\-]*-//" | grep -v $CURRENT_KERNEL | sort -rh)
for v in $VERSIONS; do
    for k in linux-image linux-headers; do
        dpkg-query -s "$k-$v" >/dev/null 2>&1 && PURGE="$PURGE $k-$v"
    done
done
apt-get remove -y --purge $PURGE

# Unique SSH keys will be generated on first boot
echo "==> Removing SSH server keys"
rm -f /etc/ssh/ssh_host_*_key*

# Unique machine ID will be generated on first boot
echo "==> Removing machine ID"
rm -f /etc/machine-id
rm -f /var/lib/dbus/machine-id

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm -rf /dev/.udev/

echo "==> Cleaning up leftover dhcp leases"
if [ -d "/var/lib/dhcp" ]; then
    rm /var/lib/dhcp/*
fi

# Generate unique keys at startup
cat > /etc/dhcp/dhclient-exit-hooks.d/setuniquekeys << EOF
dpkg-reconfigure -fnoninteractive openssh-server
systemd-machine-id-setup
rm -f /etc/dhcp/dhclient-exit-hooks.d/setuniquekeys
EOF
chmod 774 /etc/dhcp/dhclient-exit-hooks.d/setuniquekeys

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Cleanup apt cache
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

#echo "==> Installed packages"
#dpkg --get-selections | grep -v deinstall

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Clean up log files
echo "==> Purging log files"
find /var/log -type f -delete
cat /dev/null > /var/log/wtmp 2>/dev/null

# Skipping the whiteout part from box-cutter -- which would just fill up the qcow2 image

# # Whiteout root
# count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
# let count--
# dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
# rm /tmp/whitespace

# # Whiteout /boot
# count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
# let count--
# dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
# rm /boot/whitespace

# # Zero out the free space to save space in the final image
# dd if=/dev/zero of=/EMPTY bs=1M
# rm -f /EMPTY

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early
# sync
