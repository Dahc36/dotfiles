SCRIPTS_DIR=./scripts

add:
	$(SCRIPTS_DIR)/add.bash
link:
	$(SCRIPTS_DIR)/link.bash

chmod:
	chmod +x $(SCRIPTS_DIR)/add.bash
	chmod +x $(SCRIPTS_DIR)/link.bash
