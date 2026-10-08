SCRIPTS_DIR=./scripts
TESTS_DIR=./tests

.PHONY: add link check restore test

add:
	bash $(SCRIPTS_DIR)/add.bash
link:
	bash $(SCRIPTS_DIR)/link.bash
check:
	bash $(SCRIPTS_DIR)/link.bash --dry-run
restore:
	bash $(SCRIPTS_DIR)/restore.bash
test:
	bash $(TESTS_DIR)/run.bash
