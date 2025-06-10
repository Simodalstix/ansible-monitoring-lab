# Ansible-Driven Monitoring Lab

This repository contains an Ansible-based lab environment for practicing centralized logging and metrics collection using:

- **VMware** VM provisioning from templates/images
- **Infrastructure as Code** with Ansible
- Centralized logging and metrics collection
- **Splunk Universal Forwarder** (on a RHEL VM)
- **Prometheus & Node Exporter** (on Ubuntu VMs)
- **Grafana** (on an Ubuntu VM)
- **Windows AD** (optional, for directory‐service telemetry)
- **pfSense** (network gateway / DHCP / DNS)

---

## Project Structure

```
.
├── inventories
│   ├── hosts.ini
│   └── group_vars
│       ├── all.yml
│       └── ubuntu.yml
├── playbooks
│   ├── splunk_forwarder.yml
│   ├── prometheus.yml
│   └── grafana.yml
├── roles
│   ├── splunk_forwarder
│   ├── prometheus
│   ├── grafana
│   └── linux_baseline
├── ansible.cfg
└── README.md
```

- **inventories/**  
  Defines your lab hosts and per-group variables.
- **playbooks/**  
  Top-level playbooks to deploy each component.
- **roles/**  
  Reusable Ansible roles for services.
- **ansible.cfg**  
  Points to your inventory and roles path.

---

## Prerequisites

1. **Ansible 2.9+** installed on your control machine
2. **VMs** spun up in VMware Workstation (or similar):
   - **RHEL VM** for Splunk Universal Forwarder
   - **Ubuntu VMs** for Prometheus, Node Exporter, Grafana
   - **Windows Server VM** (AD) — optional
   - **pfSense VM** as DHCP/DNS gateway
3. **SSH key** set up for Linux VMs; WinRM credentials for Windows

---

## Inventory & Variables

**`inventories/hosts.ini`**

```ini
[ubuntu]
prometheus.lab.local   ansible_host=192.168.198.21   ansible_user=ansible   ansible_become=yes
grafana.lab.local      ansible_host=192.168.198.22   ansible_user=ansible   ansible_become=yes

[splunk]
splunk.lab.local       ansible_host=192.168.198.20   ansible_user=ansible   ansible_become=yes

[adserver]
adserver.lab.local     ansible_host=192.168.198.10   ansible_user=Administrator   ansible_password='Polar#618'   ansible_connection=winrm   ansible_winrm_transport=basic   ansible_winrm_server_cert_validation=ignore
```

**`inventories/group_vars/ubuntu.yml`**

```yaml
prometheus_version: "2.46.0"
node_exporter_version: "1.6.1"

grafana_repo_url: "https://packages.grafana.com/oss/deb"
grafana_signing_key_url: "https://packages.grafana.com/gpg.key"

# Splunk Universal Forwarder (RHEL VM approach)
splunk_forwarder_version: "9.4.3"
splunk_download_url_rpm: "https://download.splunk.com/products/universalforwarder/releases/9.4.3/linux/splunkforwarder-9.4.3-Linux-x86_64.rpm"
splunk_install_dir: /opt/splunkforwarder
splunk_admin_user: admin
splunk_admin_password: changeme
splunk_server: splunk.lab.local
splunk_server_port: 9997
forwarder_inputs:
  - { stanza: "[monitor:///var/log]", index: "main", sourcetype: "syslog" }
```

**`inventories/group_vars/all.yml`**

```yaml
ansible_become_password: polar
ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```

---

## Usage

1. **Verify Inventory**
   ```bash
   ansible-inventory -i inventories/hosts.ini --list
   ```
2. **Deploy Splunk Forwarder** (RHEL VM)
   ```bash
   ansible-playbook -i inventories/hosts.ini playbooks/splunk_forwarder.yml -l splunk.lab.local
   ```
3. **Deploy Prometheus & Node Exporter**
   ```bash
   ansible-playbook -i inventories/hosts.ini playbooks/prometheus.yml -l prometheus.lab.local
   ```
4. **Deploy Grafana**
   ```bash
   ansible-playbook -i inventories/hosts.ini playbooks/grafana.yml -l grafana.lab.local
   ```

---

## Monitoring Targets

- **App-stack VM** (nginx + API + DB) is recommended for realistic traffic and metrics.
- **Windows AD** as an optional log source (Windows Universal Forwarder).

---

## Next Steps

- **Kubernetes + Jenkins Lab**: CI/CD pipelines, containerized apps, cluster monitoring.
- **Enhancements**: Alerts in Prometheus, sample microservices, automated certs via Ansible.

---
