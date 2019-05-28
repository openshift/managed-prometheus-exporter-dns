#Project specific values
YAML_DIRECTORY?=deploy
SELECTOR_SYNC_SET_TEMPLATE?=scripts/templates/selectorsyncset.yaml
GIT_ROOT?=$(shell git rev-parse --show-toplevel 2>&1)
SELECTOR_SYNC_SET_DESTINATION?=${GIT_ROOT}/hack/00-osd-managed-prometheus-exporter-dns.selectorsyncset.yaml.tmpl
GIT_HASH?=$(shell git rev-parse --short=7 HEAD 2>&1)