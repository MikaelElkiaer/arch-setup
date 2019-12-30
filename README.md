# Additional set-up

## System

### VPN

```
sudo pacman -S openvpn
yay -S --noconfirm aur/openvpn-update-systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

In `/etc/nsswitch.conf`, move `dns` before `resolve` in the `hosts:` line.

```
# add to any client config to ensure DNS re-configuring
script-security 2
setenv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
up /etc/openvpn/scripts/update-systemd-resolved
up-restart
down /etc/openvpn/scripts/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .
```

## Development

### Docker

```
# install package
sudo pacman -S docker

# start service (slow startup, breaks login when enabled)
systemctl start docker

# add user to docker group (won't work until next login)
sudo usermod -aG docker $USER
```

### .NET Core

```
# download script and make it executable
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh

# install one or more versions (for other than latest, use specific version numbers from https://dotnet.microsoft.com/download/dotnet-core)
./dotnet-install.sh --install-dir /opt/dotnet -channel LTS -version latest
PATH=/opt/dotnet:$PATH
```
