# Contributing

## Quick Guidelines

- Keep it simple - this is a learning lab, not production code
- Test changes on a VM before submitting
- Follow existing code style in roles
- Update README if adding new features

## Testing Changes

```bash
# Syntax check
ansible-playbook -i inventories/hosts.ini playbooks/main.yml --syntax-check

# Dry run
ansible-playbook -i inventories/hosts.ini playbooks/main.yml --check

# Deploy to test VM
ansible-playbook -i inventories/hosts.ini playbooks/main.yml -K
```

## Role Structure

Keep roles minimal and focused:
- Use `defaults/main.yml` for variables
- Keep tasks in `tasks/main.yml`
- Use handlers for service restarts
- Template files go in `templates/`