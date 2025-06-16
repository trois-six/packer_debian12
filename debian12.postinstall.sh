# Cleanup the sources.list
:> /etc/apt/sources.list
mv /home/debian/debian.sources /etc/apt/sources.list.d/debian.sources
chmod 644 /etc/apt/sources.list.d/debian.sources 
chown root:root /etc/apt/sources.list.d/debian.sources

# Update the box
apt-get -y update
apt-get -y dist-upgrade 
