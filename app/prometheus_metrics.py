import time
from kubernetes import client, config
from prometheus_client import start_http_server, Gauge
# -------------------------
# Kubernetes API Setup
# -------------------------
def get_k8s_client():
    """
    Initializes Kubernetes API client from local kubeconfig.
    """
    config.load_kube_config()
    return client.CoreV1Api(), client.AppsV1Api()

# -------------------------
# Prometheus Gauges
# -------------------------
node_unhealthy_gauge = Gauge("k8s_node_unhealthy", "Number of unhealthy nodes")
pod_unhealthy_gauge = Gauge("k8s_pod_unhealthy", "Number of unhealthy pods")
pod_restart_gauge = Gauge("k8s_pod_restart_count", "Total restarts for unhealthy pods")
deployment_unavailable_gauge = Gauge("k8s_deployment_unavailable", "Number of unavailable replicas in deployments")

# -------------------------
# Monitoring Functions
# -------------------------
def monitor_nodes(v1):
    """
    Check node readiness and return number of unhealthy nodes.
    """
    unhealthy_nodes = 0
    for node in v1.list_node().items:
        for condition in node.status.conditions:
            if condition.type == "Ready" and condition.status != "True":
                unhealthy_nodes += 1
    return unhealthy_nodes

def monitor_pods(v1):
    """
    Check pod status and restarts.
    """
    unhealthy_pods = 0
    total_restarts = 0
    for pod in v1.list_pod_for_all_namespaces().items:
        if pod.status.phase not in ["Running", "Succeeded"]:
            unhealthy_pods += 1
            total_restarts += sum([c.restart_count for c in pod.status.container_statuses or []])
    return unhealthy_pods, total_restarts

def monitor_deployments(apps_v1):
    """
    Check deployments for unavailable replicas.
    """
    unavailable_replicas = 0
    for dep in apps_v1.list_deployment_for_all_namespaces().items:
        unavailable = dep.status.unavailable_replicas or 0
        unavailable_replicas += unavailable
    return unavailable_replicas

# -------------------------
# Main Function
# -------------------------
def main():
    v1, apps_v1 = get_k8s_client()
    
    # Start Prometheus metrics server
    start_http_server(8000)
    print("Prometheus metrics server started on port 8000")

    while True:
        # Node metrics
        unhealthy_nodes = monitor_nodes(v1)
        node_unhealthy_gauge.set(unhealthy_nodes)

        # Pod metrics
        unhealthy_pods, total_restarts = monitor_pods(v1)
        pod_unhealthy_gauge.set(unhealthy_pods)
        pod_restart_gauge.set(total_restarts)

        # Deployment metrics
        unavailable_deployments = monitor_deployments(apps_v1)
        deployment_unavailable_gauge.set(unavailable_deployments)

        # Optional: print to console
        print(f"Nodes Unhealthy: {unhealthy_nodes}, Pods Unhealthy: {unhealthy_pods}, Pod Restarts: {total_restarts}, Deployments Unavailable: {unavailable_deployments}")

        time.sleep(30)  # Refresh interval

if __name__ == "__main__":
    main()