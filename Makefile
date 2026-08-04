SCRIPTS_DIR=./scripts
TESTS_DIR=./tests

add:
	$(SCRIPTS_DIR)/add.bash
link:
	$(SCRIPTS_DIR)/link.bash
test:
	$(TESTS_DIR)/run

chmod:
	chmod +x $(SCRIPTS_DIR)/*
	chmod +x $(TESTS_DIR)/run
