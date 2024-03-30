SCRIPTS_DIR=scripts

init:
	$(SCRIPTS_DIR)/init.bash

update:
	$(SCRIPTS_DIR)/update.bash

chmod:
	chmod +x $(SCRIPTS_DIR)/init.bash
	chmod +x $(SCRIPTS_DIR)/update.bash
