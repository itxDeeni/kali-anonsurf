#!/bin/bash
set -e

# Ensure we are being ran as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be ran as root"
    exit 1
fi

# For upgrades and sanity check, remove any existing i2p.list file
rm -f /etc/apt/sources.list.d/i2p.list

# Install gnupg if not installed
if ! command -v gpg > /dev/null; then
    apt-get update
    apt-get install -y gnupg curl
fi

# Compile the i2p ppa
echo "deb [signed-by=/usr/share/keyrings/i2p-archive-keyring.gpg] https://deb.i2p.net/ $(dpkg --status tzdata | grep Provides | cut -f2 -d'-') main" > /etc/apt/sources.list.d/i2p.list

# Download i2p GPG key and display fingerprint for manual verification
curl -sLo /tmp/i2p-archive-keyring.gpg "https://i2p.net/i2p-archive-keyring.gpg"
chmod 644 /tmp/i2p-archive-keyring.gpg

echo ""
echo "i2p GPG key fingerprint:"
gpg --show-keys /tmp/i2p-archive-keyring.gpg 2>/dev/null || echo "(unable to display fingerprint)"
echo ""
echo "Verify this fingerprint at https://geti2p.net/en/download before continuing."
echo ""

mv /tmp/i2p-archive-keyring.gpg /usr/share/keyrings/i2p-archive-keyring.gpg
apt-get update

# Install dependencies
apt-get install -y secure-delete tor i2p i2p-router curl

# Configure and install the .deb
chmod 755 -R kali-anonsurf-deb-src/DEBIAN

# Check if fakeroot is installed
if command -v fakeroot > /dev/null; then
    echo "fakeroot is available, using it to build the .deb package."
    fakeroot dpkg-deb -b kali-anonsurf-deb-src/ kali-anonsurf.deb
else
    echo "fakeroot is not available, building the .deb package without it."
    dpkg-deb -b kali-anonsurf-deb-src/ kali-anonsurf.deb
fi

dpkg -i kali-anonsurf.deb || (apt-get -f install -y && dpkg -i kali-anonsurf.deb)

# Check if kali-anonsurf package is installed
if ! dpkg -l | grep -qw kali-anonsurf; then
    echo "The package 'kali-anonsurf' did not install successfully."
    exit 1
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  anonsurf start     - Start transparent Tor proxy"
echo "  anonsurf stop      - Stop transparent Tor proxy"
echo "  anonsurf status    - Check status and DNS leak test"
echo "  anonsurf myip     - Show current IP"
echo "  pandora bomb       - Wipe RAM"
echo ""
echo "Configuration: /etc/anonsurf/anonsurf.conf"
echo "Log file:       /var/log/anonsurf.log"

exit 0
