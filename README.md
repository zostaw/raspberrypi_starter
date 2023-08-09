# About

This is script that prepares SD Card before first boot.
Currently, it runs on Linux-Ubuntu and should be executed with root.

# Prerequisites

- SD Card
- Raspberry Pi OS image (.img)

# Usage

1. generate password hash for new raspberry login, for example:

```bash
echo 'mypassword' | openssl passwd -6 -stdin | sed 's/^/mynewlogin:/g'
```

2. Find name of SD Card in /dev, it can be found by searching:

```bash
fdisk -l
```

SD Card can be found by size.

3. Prepare params.sh accordingly (see params.sh.example)

4. Execute ./starter.sh params.sh (as root)
