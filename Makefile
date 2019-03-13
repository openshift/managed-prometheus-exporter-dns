SHELL := /bin/bash

# All of the source files which compose the monitor. 
# Important note: No directory structure will be maintained
SOURCEFILES ?= monitor/main.py monitor/start.sh

IMAGE_VERSION ?= stable
INIT_IMAGE_VERSION ?= 1903.0.0

RESOURCELIST := servicemonitor/dns-latency-exporter service/dns-latency-exporter daemonset/dns-latency-exporter configmap/dns-latency-exporter-code rolebinding/sre-dns-latency-exporter serviceaccount/sre-dns-latency-exporter

all: deploy/025_sourcecode.yaml deploy/040_daemonset.yaml

.PHONY: check-env
# Nothing to do, but let's leave the target to have it in all the places
check-env:

deploy/025_sourcecode.yaml: $(SOURCEFILES)
	@for sfile in $(SOURCEFILES); do \
		files="--from-file=$$sfile $$files" ; \
	done ; \
	kubectl -n openshift-monitoring create configmap dns-latency-exporter-code --dry-run=true -o yaml $$files 1> deploy/025_sourcecode.yaml

deploy/040_daemonset.yaml: resources/040_daemonset.yaml.tmpl
	@sed \
		-e "s/\$$IMAGE_VERSION/$(IMAGE_VERSION)/g" \
		-e "s/\$$INIT_IMAGE_VERSION/$(INIT_IMAGE_VERSION)/g" \
	resources/040_daemonset.yaml.tmpl 1> deploy/040_daemonset.yaml

.PHONY: clean
clean:
	rm -f deploy/025_sourcecode.yaml deploy/040_daemonset.yaml

.PHONY: filelist
filelist: all
	@ls -1 deploy/*.y*ml

.PHONE: resourcelist
resourcelist:
	@echo $(RESOURCELIST)