# About

Script that prepares builds Raspberry Pi SD Card before first boot.
Currently, it supports Ubuntu execution host (and Raspberry Pi OS for Raspberry Pi) and should be executed with root.

# Prerequisites

- empty SD Card
- Raspberry Pi OS image (.img)
- Ubuntu host with SD Card slot

# Usage

1. Generate password hash for new raspberry login, for example:

```bash
echo 'mypassword' | openssl passwd -6 -stdin | sed 's/^/mynewlogin:/g'
```

2. Find name of SD Card in /dev, it can be found by searching:

```bash
fdisk -l
```

SD Card can be found by size.

3. Prepare params.sh accordingly (see params.sh.example)

4. Execute *./starter.sh params.sh* (as root)
