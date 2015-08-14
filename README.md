# nginx-deb-cacher
Debian and Ubuntu cache on top of nginx.

# Quickie how to

`./setup.sh vars && vagrant up`

This will spin up a debian VM with the IP `192.168.33.253`. To use the cache just configure the `apt.conf` by adding `Acquire::http::Proxy "http://192.168.33.253:80"`. You can also `export http_proxy=http://192.168.33.253:80`.

# Configuration

1) Just edit the `vars` file:

```
# The desired IP address and mask of the VM
DEB_CACHE_IP_ADDR="192.168.33.253"
DEB_CACHE_IP_MASK="192.168.33.0/24"

# Mirrors - you may want to change to a nearby location
DEB_CACHE_DEB_MIR=ftp.us.debian.org
DEB_CACHE_DEB_SMIR=security.debian.org
DEB_CACHE_UBU_MIR=us.archive.ubuntu.com
DEB_CACHE_UBU_SMIR=security.ubuntu.com
```

2) Run `setup.sh vars` to generate configured files. In particular, this will generate the `Vagrantfile` with the configured interface to access the proxy.
