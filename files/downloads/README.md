# Downloads Directory

This directory contains manually downloaded software packages that require authentication or special licensing.

## Required Downloads

### Splunk Enterprise

- **File:** `splunk-9.4.0-Linux-x86_64.rpm`
- **Source:** https://www.splunk.com/en_us/download/splunk-enterprise.html
- **Purpose:** Main Splunk indexer installation
- **Target:** RHEL indexer hosts

### Splunk Universal Forwarder

- **RPM File:** `splunkforwarder-9.4.0-Linux-x86_64.rpm`
- **DEB File:** `splunkforwarder-9.4.0-linux-2.6-amd64.deb`
- **Source:** https://www.splunk.com/en_us/download/universal-forwarder.html
- **Purpose:** Log forwarding from client systems
- **Target:** Ubuntu and RHEL forwarder hosts

## Download Instructions

1. Visit the Splunk download pages (requires free account)
2. Download the appropriate packages for your version
3. Place them in this directory with the exact filenames shown above
4. Ensure file permissions are readable by Ansible

## File Structure

```
files/downloads/
├── README.md
├── splunk-9.4.0-Linux-x86_64.rpm
├── splunkforwarder-9.4.0-Linux-x86_64.rpm
└── splunkforwarder-9.4.0-linux-2.6-amd64.deb
```

## Notes

- **Grafana** and **Prometheus** download automatically from public repositories
- Only **Splunk** products require manual download due to licensing
- Update version numbers in role defaults if using different versions
- Files in this directory are ignored by git (see .gitignore)
