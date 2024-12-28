# unifi-controller-systemd

Systemd units for self-hosting a unifi-controller using podman quadlets.

### Setup

Running these just recipes will install the systemd units in user mode under
`~/.config/containers/systemd/unifi-controller`:

```bash
# creates a variables.env file with new passwords that will be used when
# templating
just init-variables
just install
```

Now you can start the units:

```bash
systemctl --user start unifi-db
systemctl --user start unifi-network-application
```

### Resources

- <https://github.com/linuxserver/docker-unifi-network-application>
- <https://wiki.archlinux.org/title/Podman#Quadlet>
- <https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html>
