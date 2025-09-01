install:
	pip3 install ansible

ping:
	ansible -i inventories/hosts.ini all -m ping

deploy:
	ansible-playbook -i inventories/hosts.ini playbooks/main.yml -K

check:
	ansible-playbook -i inventories/hosts.ini playbooks/main.yml --check

syntax:
	ansible-playbook -i inventories/hosts.ini playbooks/main.yml --syntax-check