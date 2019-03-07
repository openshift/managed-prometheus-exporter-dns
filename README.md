<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Monitor Overview](#monitor-overview)
- [Metrics](#metrics)
- [Diagnosing alerts](#diagnosing-alerts)
  - [DNSLatency200ms](#dnslatency200ms)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


<!-- Install doctoc with `npm install -g doctoc`  then `doctoc readme.md --github` -->

# Monitor Overview
Every minute, the dns test attempts to resolve redhat.com and times how long it takes.

An alert is triggered if dns resolution for the last 5 minutes averages above 200ms.

# Metrics
Note: These amounts reset each time the test is installed or restarted.
- `dns_latency_milliseconds` - The time spent resolving dns
- `dns_failure_failure_total` - The total number of dns errors encountered during tests

## Installation Process

Installation of the exporter is a multi-step process. Step one is to use the provided Makefile to render various templates into OpenShift YAML manifests.

### Rendering Templates with Make

Optionally, a different image version can be provided with the `IMAGE_VERSION` variable to  `make`. The defalt is `stable`.

`make all` will render these manifests:

* `deploy/025_sourcecode.yaml`
* `deploy/040_daemonset.yaml`

Once these have been created the collection of manifests can be applied in the usual fashion (such as `oc apply -f`).

### Additional Make Targets

The Makefile includes three helpful targets:

* `clean` - Delete any of the rendered manifest files which the Makefile renders
* `filelist` - Echos to the terminal a list of all the YAML files in the `deploy` directory
* `resourcelist` - Echos to the terminal a list of OpenShift/Kubernetes objects created by the manifests in the `deploy` directory, which may be useful for those wishing to delete the installation of this monitor.

### Prometheus Rules

Rules are provided by the [openshift/managed-cluster-config](https://github.com/openshift/managed-cluster-config) repository.
