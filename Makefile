.PHONY: install run

install:
@git pull
@bash install.sh
@python run.py

run:
@python run.py