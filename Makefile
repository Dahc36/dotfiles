SCRIPTS_DIR=./scripts
TESTS_DIR=./tests

.PHONY: add link check diff pull restore test

add:
	bash $(SCRIPTS_DIR)/add.bash
link:
	bash $(SCRIPTS_DIR)/link.bash
check:
	bash $(SCRIPTS_DIR)/link.bash --dry-run
diff:
	bash $(SCRIPTS_DIR)/diff.bash
pull:
	bash $(SCRIPTS_DIR)/pull.bash
restore:
	bash $(SCRIPTS_DIR)/restore.bash
test:
	bash $(TESTS_DIR)/run.bash
