# Active Directory Domain Join Guide (Ubuntu & RHEL)

This guide outlines the steps to join Linux machines (Ubuntu and Red Hat Enterprise Linux) to a Microsoft Active Directory domain, specifically `simo.local`. It also includes critical troubleshooting steps for common issues related to network, DNS, and time synchronization.

## Table of Contents

1.  [Introduction](#1-introduction)
2.  [Prerequisites](#2-prerequisites)
3.  [Common Troubleshooting & Lessons Learned](#3-common-troubleshooting--lessons-learned)
    - [Physical Network Connectivity](#physical-network-connectivity)
    - [Firewall/Gateway (pfSense) Connectivity](#firewallgateway-pfsense-connectivity)
    - [Active Directory (AD01) DNS Forwarders](#active-directory-ad01-dns-forwarders)
    - [Active Directory (AD01) Time Synchronization](#active-directory-ad01-time-synchronization)
    - [Linux Client DNS Configuration](#linux-client-dns-configuration)
    - [Linux Client Time Synchronization](#linux-client-time-synchronization)
4.  [Steps for Ubuntu to Join AD](#4-steps-for-ubuntu-to-join-ad)
5.  [Steps for RHEL to Join AD](#5-steps-for-rhel-to-join-ad)
6.  [Post-Join Verification](#6-post-join-verification)

---

## 1. Introduction

Joining Linux machines to an Active Directory domain allows for centralized user authentication and management, streamlining administration in mixed environments. This guide specifically addresses the `simo.local` domain, with `AD01` (IP: `192.168.198.10`) serving as the Domain Controller and DNS server.

## 2. Prerequisites

Before attempting to join any Linux client to the domain, ensure the following are in place and correctly configured:

- **Active Directory Domain Controller (AD01: `192.168.198.10`)**:
  - AD DS role installed and domain `simo.local` created.
  - DNS Server role installed, configured to host the `simo.local` zone.
  - DNS forwarders configured (e.g., to public DNS servers like `8.8.8.8`, `1.1.1.1`) to resolve external names.
  - Windows Time Service (`w32tm`) is correctly synchronizing with an external NTP source (e.g., `0.pool.ntp.org`, `1.pool.ntp.org`).
  - Appropriate firewall rules to allow NTP (UDP/123), DNS (UDP/TCP 53), Kerberos (UDP/TCP 88), and LDAP (TCP 389, 636) traffic.
- **Network Gateway/Firewall (pfSense-02)**:
  - The WAN interface (`em0`) must have a valid IP address and internet connectivity.
  - The LAN interface (`em1`) must be configured on the `192.168.198.0/24` network (e.g., `192.168.198.2`).
  - Correct routing to allow traffic between the LAN segment and the internet.
- **Linux Client Machine**:
  - Static IP address on the `192.168.198.0/24` network.
  - Primary DNS server configured to `192.168.198.10` (AD01).
  - Time synchronized with AD01.
  - Hostname configured (e.g., `ubuntu04`, `rhel01`).

## 3. Common Troubleshooting & Lessons Learned

During our session, we encountered several common pitfalls that are crucial to address before successful domain joins. These lessons apply to both Ubuntu and RHEL.

### Physical Network Connectivity

- **Problem:** The virtual network (and thus the pfSense WAN) was offline due to a physical Ethernet cable being unplugged from the host machine.
- **Lesson Learned:** Always check the most basic physical layer first. No amount of software configuration will fix a disconnected cable.
- **Verification:** Ensure all physical network cables are securely plugged in.

### Firewall/Gateway (pfSense) Connectivity

- **Problem:** pfSense's WAN interface (`em0`) had lost its IP address, preventing any internet connectivity for the virtual network. This manifested as DNS resolution failures for external domains.
- **Lesson Learned:** Your network gateway is fundamental. If it's not online and routing, nothing behind it can reach the internet.
- **Resolution:** Reconfigure `em0` on pfSense to obtain/assign an IP address. For VMware NAT, ensure `em0` is configured for DHCP.
- **Verification:** From the pfSense console, confirm `em0` has an IP. Ping a public IP (e.g., `ping 8.8.8.8`).

### Active Directory (AD01) DNS Forwarders

- **Problem:** Even with pfSense online, the AD server (AD01) couldn't resolve external DNS names (like `1.pool.ntp.org`), leading to `SERVFAIL` errors when Linux clients queried it.
- **Lesson Learned:** A Domain Controller's DNS server needs to be able to resolve names it doesn't authoritatively host. This is done via **DNS Forwarders**.
- **Resolution (on AD01):**
  1.  Open **DNS Manager**.
  2.  Right-click your server name (AD01) -> **Properties**.
  3.  Go to the **Forwarders** tab.
  4.  Add reliable public DNS servers (e.g., `8.8.8.8`, `1.1.1.1`).
  5.  Test the forwarders.
- **Verification (from AD01 CLI):**
  ```powershell
  nslookup 1.pool.ntp.org
  nslookup google.com
  ```
  Both should return IP addresses.

### Active Directory (AD01) Time Synchronization

- **Problem:** AD01's NtpClient was failing to synchronize due to the DNS resolution error for `1.pool.ntp.org` (Error `0x80072AFA`). This is critical because Kerberos authentication in AD relies heavily on accurate time synchronization between client and server.
- **Lesson Learned:** Accurate time synchronization is paramount in an Active Directory environment. If the DC isn't synchronized, clients won't be able to authenticate.
- **Resolution (on AD01 - after fixing DNS forwarders):**
  1.  Open **elevated Command Prompt** or PowerShell.
  2.  Check current status:
      ```powershell
      w32tm /query /status
      ```
  3.  Force a resync (if needed, or after initial setup):
      ```powershell
      net stop w32time
      w32tm /unregister # Use sparingly, for deep issues
      w32tm /register
      net start w32time
      w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org,0x8 1.pool.ntp.org,0x8"
      w32tm /config /update
      w32tm /resync /force
      ```
- **Verification (on AD01):**
  ```powershell
  w32tm /query /status
  ```
  Look for `Last Successful Sync Time` to be recent and `Source` to be your configured NTP pool server.

### Linux Client DNS Configuration

- **Problem:** Linux clients couldn't resolve `simo.local` or external names if their DNS was misconfigured.
- **Lesson Learned:** The Linux client must explicitly use the Domain Controller as its primary DNS server.
- **Resolution (on Linux client - example for RHEL/CentOS with NetworkManager):**
  - **Graphical:** Use NetworkManager settings to set `192.168.198.10` as the DNS server and `simo.local` as the search domain.
  - **`/etc/resolv.conf` (temporary or for manual config):**
    ```ini
    nameserver 192.168.198.10
    search simo.local
    ```
    _(Note: For NetworkManager-managed systems, changes to `/etc/resolv.conf` might be overwritten. Use `nmcli` or GUI.)_
- **Verification (on Linux client CLI):**

  ```bash
  nslookup simo.local
  # Should resolve to 192.168.198.10

  nslookup ad01.simo.local
  # Should resolve to 192.168.198.10

  nslookup 1.pool.ntp.org
  # Should resolve to multiple IPs
  ```

  _(Lesson: `search` is a config directive for `resolv.conf`, not a shell command. `bash: search: command not found...` is expected if you try to run it directly.)_

### Linux Client Time Synchronization

- **Problem:** Even with AD01 synchronized, the Linux client's clock was significantly off, preventing successful Kerberos authentication during domain join.
- **Lesson Learned:** Time synchronization is critical. Ensure your Linux client synchronizes with the Domain Controller (which is the authoritative time source for the domain).
- **Resolution (on Linux client - using `chrony` for RHEL/Ubuntu):**
  1.  Edit `/etc/chrony.conf` (or `/etc/chrony/chrony.conf` on some systems):
      Comment out or remove existing `pool` lines and add:
      ```ini
      server 192.168.198.10 iburst # Your AD DC IP
      ```
  2.  Restart chrony service:
      ```bash
      sudo systemctl restart chronyd
      ```
- **Verification (on Linux client):**

  ```bash
  chronyc sources
  # Look for '*' next to 192.168.198.10

  chronyc tracking
  # Look for 'Leap status: Normal' and 'Reference ID: C0A8C60A (192.168.198.10)'

  timedatectl status
  # Look for 'System clock synchronized: yes'
  ```

## 4. Steps for Ubuntu to Join AD

These steps assume the "Common Troubleshooting" section has been addressed.

1.  **Update System:**
    ```bash
    sudo apt update
    sudo apt upgrade -y
    ```
2.  **Install Required Packages:**
    ```bash
    sudo apt install realmd sssd adcli krb5-user packagekit-tools -y
    ```
3.  **Configure `/etc/resolv.conf`:**
    Ensure it points to your AD DC and includes the search domain. For NetworkManager-managed systems, configure this via `netplan` (Ubuntu Desktop) or `cloud-init` / `networkd` configs.
    Example `/etc/netplan/01-netcfg.yaml` (adjust interface name `enp0s3`):
    ```yaml
    network:
      version: 2
      renderer: networkd
      ethernets:
        enp0s3:
          dhcp4: no
          addresses: [192.168.198.X/24] # Replace X with your client's IP
          routes:
            - to: default
              via: 192.168.198.2 # Your pfSense LAN IP
          nameservers:
            addresses: [192.168.198.10] # Your AD DC IP
            search: [simo.local]
    ```
    Apply changes: `sudo netplan apply`
4.  **Discover the Domain:**
    ```bash
    sudo realm discover simo.local
    ```
    This should output details about your domain.
5.  **Join the Domain:**
    ```bash
    sudo realm join --user=Administrator simo.local
    ```
    Enter the password for the Active Directory Administrator.
6.  **Configure SSSD (Optional but Recommended):**
    `realm join` usually configures SSSD automatically. You can verify and adjust settings in `/etc/sssd/sssd.conf` if needed (e.g., to enable `id_provider=ad`, `auth_provider=ad`). Ensure `use_fully_qualified_names = False` if you want to log in as `username` instead of `username@simo.local`.
7.  **Configure Login (PAM):**
    For GUI login, you might need to enable SSSD in `/etc/pam.d/common-session` and `/etc/pam.d/common-auth`. Often, `realmd` handles this.
8.  **Allow Home Directory Creation (Optional but Recommended):**
    Edit `/etc/pam.d/common-session` and add the line:
    ```
    session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
    ```
9.  **Allow AD Users to Login (Optional):**
    By default, only domain administrators can log in. To allow a specific group (e.g., `Domain Users` or a custom group), use:
    ```bash
    sudo realm permit -g 'Domain Users@simo.local' # Or your custom group
    ```
    To allow _all_ domain users (less secure for production):
    ```bash
    sudo realm permit --all
    ```
10. **Reboot the system.**

## 5. Steps for RHEL to Join AD

These steps also assume the "Common Troubleshooting" section has been addressed, especially the RHEL-specific time sync solution.

1.  **Update System:**
    ```bash
    sudo yum update -y # Or dnf update -y
    ```
2.  **Install Required Packages:**
    ```bash
    sudo yum install realmd sssd adcli krb5-workstation authselect-compat -y
    ```
3.  **Configure NetworkManager (Recommended for RHEL):**
    - **Graphical:** Go to network settings, set static IP, set DNS to `192.168.198.10`, and add `simo.local` to the search domains.
    - **`nmcli`:**
      ```bash
      sudo nmcli connection modify "Your_Connection_Name" ipv4.addresses 192.168.198.X/24
      sudo nmcli connection modify "Your_Connection_Name" ipv4.gateway 192.168.198.2
      sudo nmcli connection modify "Your_Connection_Name" ipv4.dns 192.168.198.10
      sudo nmcli connection modify "Your_Connection_Name" ipv4.dns-search simo.local
      sudo nmcli connection up "Your_Connection_Name"
      ```
    - Verify `/etc/resolv.conf` now points to `192.168.198.10` and has `search simo.local`.
4.  **Set Static Hostname (Crucial for RHEL/AD):**
    ```bash
    sudo hostnamectl set-hostname rhel01 # Use your desired hostname
    ```
    **Verification:**
    ```bash
    hostnamectl status
    hostname -f # Should now show rhel01.simo.local (or similar)
    ```
5.  **Configure Chrony for Time Sync (Crucial for RHEL/AD):**
    Edit `/etc/chrony.conf`:

    ```ini
    # Comment out default pool lines
    # pool 2.rhel.pool.ntp.org iburst

    # Add your AD Domain Controller as the sole NTP server
    server 192.168.198.10 iburst

    # Allow NTP client access from 192.168.198.0/24 (optional, if AD01 isn't your only chrony client)
    # allow 192.168.198.0/24
    ```

    Restart Chrony:

    ```bash
    sudo systemctl restart chronyd
    ```

    **Verification:**

    ```bash
    chronyc sources
    # Look for '*' next to 192.168.198.10

    chronyc tracking
    # Look for 'Leap status: Normal' and 'Reference ID: C0A8C60A (192.168.198.10)'

    timedatectl status
    # Look for 'System clock synchronized: yes'
    ```

6.  **Discover the Domain:**
    ```bash
    sudo realm discover simo.local
    ```
7.  **Join the Domain:**
    ```bash
    sudo realm join --user=Administrator simo.local
    ```
    Enter the password for the Active Directory Administrator.
8.  **Configure SSSD and PAM using `authselect`:**
    RHEL/CentOS 8+ use `authselect` for PAM and NSS configurations.
    ```bash
    sudo authselect select sssd with-mkhomedir --force
    # If you need to enable SSH login for AD users:
    sudo authselect enable-feature with-sudo
    sudo authselect apply-changes
    ```
    This command enables SSSD as the authentication source and configures automatic home directory creation for AD users.
9.  **Allow AD Users to Login (Optional):**
    Similar to Ubuntu, you can control which AD users/groups can log in:
    ```bash
    sudo realm permit -g 'Domain Users@simo.local'
    # Or to allow specific users
    sudo realm permit -u 'aduser@simo.local'
    ```
10. **Reboot the system.**

## 6. Post-Join Verification

After rebooting your Linux client, verify the domain join and user authentication:

1.  **Check Domain Status:**
    ```bash
    realm list
    ```
    This should show `configured: kerberos-member` and list `simo.local`.
2.  **Verify AD User Information:**
    ```bash
    id aduser@simo.local # Replace 'aduser' with an actual AD username
    ```
    This should return the user's UID, GID, and groups.
3.  **Test Authentication:**
    Try logging in as an Active Directory user (e.g., `su - aduser@simo.local`). If you configured `use_fully_qualified_names = False` in SSSD, you might be able to log in simply as `aduser`.
