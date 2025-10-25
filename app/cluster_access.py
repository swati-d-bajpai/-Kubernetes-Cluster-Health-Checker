# cluster_access.py
from kubernetes import client, config

def get_k8s_client():
    # Load local kubeconfig
    config.load_kube_config()
    return client.CoreV1Api(), client.AppsV1Api()

def check_nodes():
    v1, _ = get_k8s_client()
    nodes_status = []
    for node in v1.list_node().items:
        node_info = {
            "name": node.metadata.name,
            "ready": True,
            "conditions": {}
        }
        for cond in node.status.conditions:
            node_info["conditions"][cond.type] = cond.status
            if cond.type == "Ready" and cond.status != "True":
                node_info["ready"] = False
        nodes_status.append(node_info)
    return nodes_status

def check_pods():
    v1, _ = get_k8s_client()
    pods_status = []
    for pod in v1.list_pod_for_all_namespaces().items:
        pod_info = {
            "namespace": pod.metadata.namespace,
            "name": pod.metadata.name,
            "phase": pod.status.phase,
            "restarts": sum([c.restart_count for c in pod.status.container_statuses or []])
        }
        pods_status.append(pod_info)
    return pods_status


def monitor_nodes():
    v1, _ = get_k8s_client()
    for node in v1.list_node().items:
        name = node.metadata.name
        conditions = {c.type: c.status for c in node.status.conditions}
        capacity = node.status.capacity
        print(f"Node: {name}")
        print(f"  Conditions: {conditions}")
        print(f"  CPU: {capacity.get('cpu')}, Memory: {capacity.get('memory')}, Pods: {capacity.get('pods')}")

def monitor_pods():
    v1, _ = get_k8s_client()
    for pod in v1.list_pod_for_all_namespaces().items:
        name = pod.metadata.name
        namespace = pod.metadata.namespace
        status = pod.status.phase
        restart_count = sum([c.restart_count for c in pod.status.container_statuses or []])
        print(f"{namespace}/{name}:")
        print(f"    {status}, Restarts: {restart_count}")

def monitor_deployments():
    apps_v1, _ = client.AppsV1Api()
    for dep in apps_v1.list_deployment_for_all_namespaces().items:
        name = dep.metadata.name
        namespace = dep.metadata.namespace
        desired = dep.spec.replicas
        available = dep.status.available_replicas or 0
        unavailable = dep.status.unavailable_replicas or 0
        print(f"{namespace}/{name}:")
        print(f"    Desired={desired}, Available={available}, Unavailable={unavailable}")

def monitor_services():
    v1, _ = get_k8s_client()
    for svc in v1.list_service_for_all_namespaces().items:
        endpoints = v1.read_namespaced_endpoints(svc.metadata.name, svc.metadata.namespace)
        ready_pods = sum([len(e.addresses or []) for e in endpoints.subsets or []])
        print(f"{svc.metadata.namespace}/{svc.metadata.name}:")
        print(f"    Ready endpoints: {ready_pods}")

def monitor_namespaces():
    v1, _ = get_k8s_client()
    for ns in v1.list_namespace().items:
        name = ns.metadata.name
        print(f"Namespace: {name}")

if __name__ == "__main__":
    # v1 = get_k8s_client()
    # print("Listing pods in all namespaces:")
    # for pod in v1.list_pod_for_all_namespaces().items:
    #     print(f"{pod.metadata.namespace} - {pod.metadata.name} - {pod.status.phase}")
    
    print("Unhealthy nodes:", check_nodes())
    print("Unhealthy pods:", check_pods())

    print("---------------")
    print("Monitor Nodes")
    print("---------------")
    monitor_nodes()

    print("---------------")
    print("Monitor Pods")
    print("---------------")
    monitor_pods()

    print("---------------")
    print("Monitor Deployments")
    print("---------------")
    monitor_deployments()
    
    print("---------------")
    print("Monitor Services")
    print("---------------")
    monitor_services()
    
    print("---------------")
    print("Monitor namespaces")
    print("---------------")
    monitor_namespaces()