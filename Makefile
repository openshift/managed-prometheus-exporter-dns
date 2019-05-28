SHELL := /bin/bash
include functions.mk
include project.mk

#Validate variables in project.mk exist
ifndef YAML_DIRECTORY
$(error YAML_DIRECTORY is not set; check project.mk file)
endif
ifndef SELECTOR_SYNC_SET_TEMPLATE
$(error SELECTOR_SYNC_SET_TEMPLATE is not set; check project.mk file)
endif
ifndef SELECTOR_SYNC_SET_DESTINATION
$(error SELECTOR_SYNC_SET_DESTINATION is not set; check project.mk file)
endif
ifndef GIT_HASH
$(error GIT_HASH is not set; check project.mk file)
endif

# Name of the exporter
EXPORTER_NAME := dns-latency-exporter
# valid: deployment or daemonset
# currently unused
EXPORTER_TYPE := daemonset

# All of the source files which compose the monitor. 
# Important note: No directory structure will be maintained
SOURCEFILES ?= monitor/main.py monitor/start.sh

# What to prefix the name of resources with?
NAME_PREFIX ?= sre-
SOURCE_CONFIGMAP_SUFFIX ?= -code
CREDENITALS_SUFFIX ?= -aws-credentials

MAIN_IMAGE_URI ?= quay.io/jupierce/openshift-python-monitoring
IMAGE_VERSION ?= stable

# Generate variables

MAIN_IMAGE ?= $(MAIN_IMAGE_URI):$(IMAGE_VERSION)

PREFIXED_NAME ?= $(NAME_PREFIX)$(EXPORTER_NAME)

AWS_CREDENTIALS_SECRET_NAME ?= $(PREFIXED_NAME)$(CREDENITALS_SUFFIX)
SOURCE_CONFIGMAP_NAME ?= $(PREFIXED_NAME)$(SOURCE_CONFIGMAP_SUFFIX)
SERVICEACCOUNT_NAME ?= $(PREFIXED_NAME)

RESOURCELIST := servicemonitor/$(PREFIXED_NAME) service/$(PREFIXED_NAME) \
	daemonset/$(PREFIXED_NAME) configmap/$(SOURCE_CONFIGMAP_NAME) \
	rolebinding/$(PREFIXED_NAME) serviceaccount/$(SERVICEACCOUNT_NAME) \
	clusterrole/sre-allow-read-cluster-setup

all: deploy/010_serviceaccount-rolebinding.yaml deploy/025_sourcecode.yaml deploy/040_daemonset.yaml deploy/050_service.yaml deploy/060_servicemonitor.yaml generate-syncset

deploy/010_serviceaccount-rolebinding.yaml: resources/010_serviceaccount-rolebinding.yaml.tmpl
	@$(call generate_file,010_serviceaccount-rolebinding)

deploy/025_sourcecode.yaml: $(SOURCEFILES)
	@for sfile in $(SOURCEFILES); do \
		files="--from-file=$$sfile $$files" ; \
	done ; \
	kubectl -n openshift-monitoring create configmap $(SOURCE_CONFIGMAP_NAME) --dry-run=true -o yaml $$files 1> deploy/025_sourcecode.yaml

deploy/040_daemonset.yaml: resources/040_daemonset.yaml.tmpl
	@$(call generate_file,040_daemonset)

deploy/050_service.yaml: resources/050_service.yaml.tmpl
	@$(call generate_file,050_service)

deploy/060_servicemonitor.yaml: resources/060_servicemonitor.yaml.tmpl
	@$(call generate_file,060_servicemonitor)

.PHONY: generate-syncset
generate-syncset: 
	scripts/generate_syncset.py -t ${SELECTOR_SYNC_SET_TEMPLATE} -y ${YAML_DIRECTORY} -d ${SELECTOR_SYNC_SET_DESTINATION} -c ${GIT_HASH}

.PHONY: clean
clean:
	rm -f deploy/*.yaml
	rm -rf ${SELECTOR_SYNC_SET_DESTINATION}

.PHONY: filelist
filelist: all
	@ls -1 deploy/*.y*ml

.PHONY: resourcelist
resourcelist:
	@echo $(RESOURCELIST)

.PHONY: git-commit-sss-template
git-commit-sss-template:
	git add ${SELECTOR_SYNC_SET_DESTINATION}
	git commit -m "Updated selectorsynceset template added"