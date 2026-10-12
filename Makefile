SCRIPTS_DIR=./scripts
TESTS_DIR=./tests

.PHONY: add link check diff restore test

add:
	bash $(SCRIPTS_DIR)/add.bash
link:
	bash $(SCRIPTS_DIR)/link.bash
check:
	bash $(SCRIPTS_DIR)/link.bash --dry-run
diff:
	bash $(SCRIPTS_DIR)/diff.bash
restore:
	bash $(SCRIPTS_DIR)/restore.bash
test:
	bash $(TESTS_DIR)/run.bash
