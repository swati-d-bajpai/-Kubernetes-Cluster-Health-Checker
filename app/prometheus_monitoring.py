from prometheus_client import start_http_server, Gauge
import time
from app.cluster_access import check_nodes, check_pods

# Define Prometheus Gauges
node_unhealthy_gauge = Gauge('k8s_node_unhealthy', 'Number of unhealthy nodes')
pod_unhealthy_gauge = Gauge('k8s_pod_unhealthy', 'Number of unhealthy pods')
pod_restart_gauge = Gauge('k8s_pod_restart_count', 'Total pod container restarts')

def update_metrics():
    nodes = check_nodes()
    pods = check_pods()

    # Node metrics
    unhealthy_nodes = sum(1 for n in nodes if not n['ready'])
    node_unhealthy_gauge.set(unhealthy_nodes)

    # Pod metrics
    unhealthy_pods = sum(1 for p in pods if p['phase'] not in ["Running", "Succeeded"])
    total_restarts = sum(p['restarts'] for p in pods)
    pod_unhealthy_gauge.set(unhealthy_pods)
    pod_restart_gauge.set(total_restarts)

if __name__ == "__main__":
    start_http_server(8000)  # Expose metrics on port 8000
    while True:
        update_metrics()
        time.sleep(5)  # Update every 5 seconds