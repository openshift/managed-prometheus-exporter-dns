# DNS Metrics Exporter Overview

Every minute, the dns metrics exporter attempts to resolve redhat.com and times how long it takes.

# Metrics

> Note: These amounts reset each time the workload is installed or restarted.

- `dns_latency_milliseconds` - The time spent resolving dns
- `dns_failure_failure_total` - The total number of dns errors encountered during tests

## Installation Process

1. Use `make` to render the YAML manifests into the `deploy` directory
2. Deploy the monitor to an OpenShift cluster with `oc apply -f deploy`

### Additional Make Targets

The Makefile includes three helpful targets:

* `clean` - Delete any of the rendered manifest files which the Makefile renders
* `filelist` - Echos to the terminal a list of all the YAML files in the `deploy` directory
* `resourcelist` - Echos to the terminal a list of OpenShift/Kubernetes objects created by the manifests in the `deploy` directory, which may be useful for those wishing to delete the installation of this monitor.

### Prometheus Rules

Rules are provided by the [openshift/managed-cluster-config](https://github.com/openshift/managed-cluster-config) repository. Currently there is only one:

* [DNSErrors10MinSRE](https://github.com/openshift/managed-cluster-config/blob/bddd03fef32059e4ff020ba9f71161ccd8b71fb9/deploy/sre-prometheus/100-dns-latency.PrometheusRule.yaml) - indicates that there has been an increase in the `dns_failure_failure_total` counter over the last 10 minutes.
