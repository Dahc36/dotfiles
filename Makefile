SCRIPTS_DIR=./scripts
TESTS_DIR=./tests

.PHONY: add link restore test

add:
	bash $(SCRIPTS_DIR)/add.bash
link:
	bash $(SCRIPTS_DIR)/link.bash
restore:
	bash $(SCRIPTS_DIR)/restore.bash
test:
	bash $(TESTS_DIR)/run.bash
