#!/usr/bin/python

import time
import logging
from prometheus_client import start_http_server, Counter, Gauge
import timeit
import traceback

MONITOR_NAME = 'DNS'
HOST = 'redhat.com'

DNS_LATENCY = Gauge('dns_latency_milliseconds', 'Time spent during dns request')
DNS_ERROR = Counter('dns_failure_failure_total', 'The total number of failures encountered resolving dns')

def run_test():
    logging.info("looking up %s", HOST)
    try:
        DNS_LATENCY.set(timeit.timeit("""
        hostname= '%s'
        try:
          socket.gethostbyname(hostname)
        except socket.gaierror as e:
          # adding the error type is from https://github.com/tao12345666333/tornado-zh/blob/e9e8519beb147d9e1290f6a4fa7d61123d1ecb1c/tornado/netutil.py#L293
          # and would hopefully allow us to understand the root of this issue
          print(f'python command "import socket; socket.gethostbyname({hostname})"')
          print(f'=== error_type: {e.args[0]} ===')
          print(f'=== err: {e} ===')
        """ % HOST, setup="import socket", number=1))
    except Exception as e:
        traceback.print_exc()
        DNS_ERROR.inc()

if __name__ == '__main__':

    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s:%(name)s:%(message)s')
    logging.info('Starting up metrics endpoint')
    # Start up the server to expose the metrics.
    start_http_server(8080)
    while True:
        logging.info('Running {} test...'.format(MONITOR_NAME))
        run_test()
        logging.info("Sleeping for 1 minute before next test...")
        time.sleep(60)
