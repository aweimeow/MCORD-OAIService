# mcord/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(CONFIG_DIR)/../common

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= mcord
BOOTSTRAP_PROJECT  ?= mcordbs

XOS_UI_PORT        :=8888

include $(COMMON_DIR)/Makefile

pull_services:
	git clone https://gerrit.opencord.org/vBBU ~/xos_services/vBBU
	git clone https://gerrit.opencord.org/vMME ~/xos_services/vMME
	git clone https://gerrit.opencord.org/vSGW ~/xos_services/vSGW
	git clone https://gerrit.opencord.org/vPGWC ~/xos_services/vPGWC

xos: prereqs config_dirs xos_download cord_services cord_libraries bootstrap onboarding podconfig

onboarding:
	@echo "[ONBOARDING]"
	# on-board any services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	sudo cp id_rsa key_import/vBBU_rsa
	sudo cp id_rsa.pub key_import/vBBU_rsa.pub
	sudo cp id_rsa key_import/vPGWC_rsa
	sudo cp id_rsa.pub key_import/vPGWC_rsa.pub
	sudo cp id_rsa key_import/vSGW_rsa
	sudo cp id_rsa.pub key_import/vSGW_rsa.pub
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa.pub key_import/onos_rsa.pub
	sudo cp id_rsa key_import/vMME_rsa
	sudo cp id_rsa.pub key_import/vMME_rsa.pub
	sudo cp id_rsa key_import/oai_rsa
	sudo cp id_rsa.pub key_import/oai_rsa.pub
	sudo cp id_rsa key_import/vsg_rsa
	sudo cp id_rsa.pub key_import/vsg_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vBBU/xos/vBBU-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vPGWC/xos/vPGWC-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vSGW/xos/vSGW-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vsg/xos/vsg-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vMME/xos/vmme-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/oai/xos/oai-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/fabric/xos/fabric-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vbbu
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vpgwc
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsgw
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsg
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vmme
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/oai
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

progran:
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/progran/xos/progran-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/progran
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

podconfig: nodes.yaml images.yaml
	@echo "[PODCONFIG]"
	# TODO: the setup create the seconde nodes.Controller named MyOpenStack, this why we delete it for now
	# we still need it because it create lots of other services like firewall on the service list
	#$(RUN_TOSCA) setup.yaml
	$(RUN_TOSCA) nodes.yaml
	$(RUN_TOSCA) images.yaml

images:
	$(RUN_TOSCA) images.yaml

vtn: vtn-external.yaml
	$(RUN_TOSCA) vtn-external.yaml

vtn-external.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-vtn-external-yaml.sh

mcord:
	$(RUN_TOSCA) mgmt-net.yaml
	$(RUN_TOSCA) mcord.yaml

onboard-slicing: slicing-ui
	@echo "[ONBOARDING]"
	# on-board slicing services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/mcord_slicing_ui/xos/mcord-slicing-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/mcord_slicing_ui
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

slicing-ui:
	$(RUN_TOSCA) ./mcord-slicing-ui.yaml
fabric:
	@echo "[FABRIC]"
	$(RUN_TOSCA) fabric.yaml
	sleep 20
delete_fabric_config:
	curl -sSL --user karaf:karaf -X DELETE http://onos-fabric:8181/onos/v1/network/configuration/

reactivate_fabric_apps:
	curl -sSL --user karaf:karaf -X POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.vrouter/active
	curl -sSL --user karaf:karaf -X POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.segmentrouting/active

deactivate_fabric_apps:
	curl -sSL --user karaf:karaf -X POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.vrouter/deactivate
	curl -sSL --user karaf:karaf -X POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.segmentrouting/deactive

experimental-ui:
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(CONFIG_DIR)/ui_containers.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)
