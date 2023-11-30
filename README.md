# About

Script that builds Raspberry Pi SD Card before first boot.
Currently, it supports Ubuntu as execution host (and Raspberry Pi OS for Raspberry Pi) and should be executed with root.

# Prerequisites

- empty microSD Card (at least 4 GB)
- Ubuntu host with SD Card slot 
- SD Card adapter
- Raspberry Pi OS image (.img) - see https://www.raspberrypi.com/software/operating-systems/

# Usage

1. Generate password hash for new raspberry login, for example:

```bash
echo 'mypassword' | openssl passwd -6 -stdin | sed 's/^/mynewlogin:/g'
```

2. Find name of SD Card in /dev, it can be found by searching:

```bash
fdisk -l
```

SD Card can be identified by size.

3. Prepare params.sh accordingly (see params.sh.example)

4. Execute *./starter.sh params.sh* (as root)

# Update 30.11.2023

Wifi is *NOT* supported since Raspberry Pi OS (12 - Bookwarm). 
The headless option was removed.
Instead you can configure wifi after connecting ssh (over ethernet) and running raspi-config.

