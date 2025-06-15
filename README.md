# Ansible Splunk Setup

This project provisions a hybrid monitoring and logging environment across VMware-based infrastructure using Ansible.

It automates:

- **Active Directory setup** for centralized domain control (on Windows Server)
- **Splunk Enterprise + Universal Forwarders** for log collection
- **Prometheus + Grafana** configuration for metrics monitoring
- Basic integration with **pfSense**, **Ubuntu**, and **RHEL** VMs

## Lab Overview

This is part of a larger enterprise-style lab running on VMware Workstation Pro. The goal is to simulate a real-world environment with centralized authentication and full-stack observability.

### Components

- **Windows Server 2022** — Domain Controller (AD DS, DNS)
- **RHEL & Ubuntu** — Linux nodes joined to the domain
- **Splunk Enterprise** — Centralized log aggregation
- **Universal Forwarders** — Installed on Linux clients
- **Prometheus + Grafana** — System metrics collection and dashboards
- **pfSense** — Firewall and routing layer

## Getting Started

1. Clone the repo:

   ```bash
   git clone https://github.com/Simodalstix/ansible-splunk-setup.git
   cd ansible-splunk-setup
   ```

2. Set up Python virtual environment and install dependencies:

   ```bash
   make install
   ```

3. Lint your Ansible config:

   ```bash
   make lint
   ```

4. Run your playbook:
   ```bash
   ansible-playbook -i inventory.yml site.yml
   ```

> Make sure you’ve set up your inventory and `group_vars` to match your VM environment.

## Screenshots (Coming Soon)

Planned additions:

- Domain-joined Linux clients with `realm list`
- Config excerpts from `/etc/sssd/sssd.conf`
- Splunk web UI + log ingestion examples
- Grafana dashboards + Prometheus targets
- AD DNS + pfSense routing setup

## Notes

- This is a work in progress.
- Designed for offline, local VMware environments — no cloud dependency.
- Inspired by real-world DevOps, Platform, and Infrastructure engineering practices.
