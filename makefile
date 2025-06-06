.PHONY: lint

venv := .venv
python := $(venv)/bin/python
pip := $(venv)/bin/pip

lint:
	@echo "Running ansible-lint..."
	$(venv)/bin/ansible-lint

install:
	python3 -m venv $(venv)
	$(pip) install --upgrade pip
	$(pip) install ansible-lint
