#/bin/sh

# Start and enable services
sudo systemctl start systemd-networkd systemd-resolved
sudo systemctl enable systemd-networkd systemd-resolved

# Set up interfaces
ETHERNET_INTERFACE=$(exa /sys/class/net | fzf --header='Select ethernet interface' | awk '{print $1}')
sudo sh -c "cat <<- EOL > /etc/systemd/network/20-wired.network
	[Match]
	Name=$ETHERNET_INTERFACE
	
	[Network]
	DHCP=ipv4
	
	[DHCP]
	UseDomains=yes
EOL"

WIRELESS_INTERFACE=$(exa /sys/class/net | fzf --header='Select wireless interface' | awk '{print $1}')
sudo sh -c "cat <<- EOL > /etc/systemd/network/25-wireless.network
	[Match]
	Name=$WIRELESS_INTERFACE
	
	[Network]
	DHCP=ipv4
	
	[DHCP]
	UseDomains=yes
EOL"

sudo systemctl restart systemd-networkd systemd-resolved
