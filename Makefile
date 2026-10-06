SCRIPTS_DIR=./scripts
TESTS_DIR=./tests

add:
	$(SCRIPTS_DIR)/add.bash
link:
	$(SCRIPTS_DIR)/link.bash
test:
	bash $(TESTS_DIR)/run.bash

chmod:
	chmod +x $(SCRIPTS_DIR)/*
	chmod +x $(TESTS_DIR)/run
