SCRIPTS_DIR=./scripts

pull:
	$(SCRIPTS_DIR)/pull.bash
push:
	$(SCRIPTS_DIR)/push.bash

add:
	$(SCRIPTS_DIR)/add.bash

chmod:
	chmod +x $(SCRIPTS_DIR)/push.bash
	chmod +x $(SCRIPTS_DIR)/pull.bash
	chmod +x $(SCRIPTS_DIR)/add.bash
