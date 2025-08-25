# Ansible Web Application Lab

This project demonstrates practical infrastructure automation using Ansible to deploy and manage a complete web application stack.

## What This Deploys

- **Django Polls App** - A functional web application with database
- **PostgreSQL** - Database backend
- **Prometheus + Grafana** - Metrics monitoring and dashboards
- **Loki + Promtail** - Log aggregation and analysis
- **Nginx** - Reverse proxy and static file serving

## Architecture

**Single App Server VM:**
- All services consolidated on one Ubuntu/RHEL VM
- Demonstrates real-world application deployment
- Full observability stack included

**Existing Infrastructure:**
- AD Server for authentication (optional integration)
- pfSense for networking/firewall

## Quick Start

1. **Setup environment:**
   ```bash
   make install
   ```

2. **Configure your inventory:**
   ```bash
   cp inventory.yml.example inventory.yml
   # Edit inventory.yml with your VM details
   ```

3. **Deploy everything:**
   ```bash
   ansible-playbook -i inventory.yml site.yml
   ```

4. **Access services:**
   - Django App: `http://your-vm:8000`
   - Grafana: `http://your-vm:3000` (admin/admin)
   - Prometheus: `http://your-vm:9090`

## What You'll Learn

- Ansible role development and best practices
- Database deployment and configuration
- Web application deployment with Django
- Monitoring stack setup (Prometheus/Grafana)
- Log aggregation with Loki
- Service orchestration and dependencies

## Project Structure

```
├── inventory.yml          # Your VM configuration
├── site.yml              # Main playbook
├── group_vars/all.yml     # Global variables
└── roles/
    ├── baseline/          # System preparation
    ├── database/          # PostgreSQL setup
    ├── webapp/            # Django application
    ├── monitoring/        # Prometheus + Grafana
    └── logging/           # Loki + Promtail
```

This is a practical, hands-on project that demonstrates real infrastructure automation scenarios you'd encounter in production environments.