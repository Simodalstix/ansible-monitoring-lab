install:
	pip3 install ansible

deploy:
	ansible-playbook -i inventory.yml site.yml

check:
	ansible-playbook -i inventory.yml site.yml --check

ping:
	ansible -i inventory.yml all -m ping