# Ansible Monitoring Lab

[![Ansible](https://img.shields.io/badge/ansible-2.9+-blue.svg)](https://www.ansible.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A practical Ansible lab that deploys a complete web application stack with monitoring on a single VM. Demonstrates Django app deployment, SQLite database, and observability stack (Prometheus, Grafana, Loki).

## Architecture

**Single VM Stack:**
- Django Polls application (port 8000)
- SQLite database (simple, zero-config)
- Prometheus metrics (port 9090)
- Grafana dashboards (port 3000)
- Loki log aggregation (port 3100)
- Nginx reverse proxy

## Prerequisites

- Ansible 2.9+
- Python 3.6+
- SSH access to target VM
- Sudo privileges on target VM

## Quick Start

1. **Install Ansible:**
   ```bash
   pip3 install ansible
   ```

2. **Configure inventory:**
   ```bash
   # Edit inventories/hosts.ini with your VM details
   vim inventories/hosts.ini
   ```

3. **Test connectivity:**
   ```bash
   ansible -i inventories/hosts.ini all -m ping
   ```

4. **Deploy stack:**
   ```bash
   ansible-playbook -i inventories/hosts.ini playbooks/site.yml -K
   ```

5. **Access services:**
   - Django App: http://your-vm:8000
   - Grafana: http://your-vm:3000 (admin/admin)
   - Prometheus: http://your-vm:9090

## Project Structure

```
├── inventories/
│   └── hosts.ini              # VM configuration
├── playbooks/
│   └── site.yml               # Main deployment playbook
├── roles/                     # Ansible roles
│   ├── baseline/              # System setup
│   ├── database/              # PostgreSQL (installed but not used)
│   ├── webapp/                # Django app with SQLite
│   ├── monitoring/            # Prometheus + Grafana
│   └── logging/               # Loki
├── group_vars/
│   └── all.yml                # Global variables
└── ansible.cfg                # Ansible configuration
```

## Troubleshooting

**SSH Issues:**
```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa ansible@your-vm-ip

# Add SSH key if needed
ssh-copy-id -i ~/.ssh/id_rsa ansible@your-vm-ip
```

**Privilege Escalation:**
```bash
# Ensure user has sudo access
sudo visudo
# Add: ansible ALL=(ALL) NOPASSWD:ALL

# Or use -K flag for password prompt
ansible-playbook -i inventories/hosts.ini playbooks/site.yml -K
```

**Connection Test:**
```bash
# Verify inventory and connectivity
ansible -i inventories/hosts.ini all -m setup --limit webservers
```