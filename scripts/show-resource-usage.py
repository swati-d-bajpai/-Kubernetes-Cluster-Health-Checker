#!/usr/bin/env python3
"""
Show Resource Usage for Kubernetes Resources
Displays CPU and Memory usage for Nodes, Pods, Namespaces, and Deployments
"""

from typing import Any, Dict, List
import requests
import sys
from datetime import datetime

# Type ignore for requests
requests  # type: ignore


def print_header() -> None:
    """Print script header"""
    print("╔══════════════════════════════════════════════════════════════════════════╗")
    print("║                                                                          ║")
    print("║              KUBERNETES RESOURCE USAGE - CPU & MEMORY                    ║")
    print("║                                                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════════╝")
    print()


def check_prometheus_connection(prometheus_url: str) -> bool:
    """Check if Prometheus is accessible"""
    try:
        response: Any = requests.get(f"{prometheus_url}/api/v1/status/config", timeout=5)
        if response.status_code == 200:
            print("✅ Connected to Prometheus")
            return True
        else:
            print(f"❌ Failed to connect to Prometheus: HTTP {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Cannot connect to Prometheus: {e}")
        print("\n💡 Make sure port-forward is running:")
        print("   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090")
        return False


def query_prometheus(prometheus_url: str, query: str) -> List[Dict[str, Any]]:
    """Query Prometheus and return results"""
    try:
        response: Any = requests.get(
            f"{prometheus_url}/api/v1/query",
            params={"query": query},
            timeout=10
        )
        if response.status_code == 200:
            data: Dict[str, Any] = response.json()
            return data.get('data', {}).get('result', [])
        else:
            print(f"❌ Query failed: HTTP {response.status_code}")
            return []
    except requests.exceptions.RequestException as e:
        print(f"❌ Error querying Prometheus: {e}")
        return []


def format_bytes(bytes_value: float) -> str:
    """Format bytes to human readable format"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_value < 1024.0:
            return f"{bytes_value:.2f} {unit}"
        bytes_value /= 1024.0
    return f"{bytes_value:.2f} PB"


def format_cpu(cpu_value: float) -> str:
    """Format CPU cores"""
    if cpu_value < 0.001:
        return f"{cpu_value * 1000:.2f} m"
    return f"{cpu_value:.3f} cores"


def show_node_resources(prometheus_url: str) -> None:
    """Show node CPU and memory usage"""
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🖥️  NODE RESOURCES")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    # CPU Usage
    cpu_query: str = '100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'
    cpu_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, cpu_query)
    
    # Memory Usage
    mem_query: str = '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100'
    mem_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, mem_query)
    
    # Memory Total
    mem_total_query: str = 'node_memory_MemTotal_bytes'
    mem_total_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, mem_total_query)
    
    print(f"{'Node':<30} {'CPU Usage':<20} {'Memory Usage':<20} {'Total Memory':<15}")
    print("─" * 85)
    
    for cpu_result in cpu_results:
        instance: str = cpu_result['metric'].get('instance', 'unknown')
        cpu_value: float = float(cpu_result['value'][1])
        
        # Find matching memory result
        mem_value: float = 0.0
        mem_total: float = 0.0
        
        for mem_result in mem_results:
            if mem_result['metric'].get('instance') == instance:
                mem_value = float(mem_result['value'][1])
                break
        
        for mem_t_result in mem_total_results:
            if mem_t_result['metric'].get('instance') == instance:
                mem_total = float(mem_t_result['value'][1])
                break
        
        cpu_icon: str = "🔴" if cpu_value > 80 else "🟡" if cpu_value > 60 else "🟢"
        mem_icon: str = "🔴" if mem_value > 85 else "🟡" if mem_value > 70 else "🟢"
        
        print(f"{instance:<30} {cpu_icon} {cpu_value:>6.2f}%{'':<10} {mem_icon} {mem_value:>6.2f}%{'':<10} {format_bytes(mem_total):<15}")


def show_namespace_resources(prometheus_url: str) -> None:
    """Show namespace CPU and memory usage"""
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📦 NAMESPACE RESOURCES")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    # CPU Usage by namespace
    cpu_query: str = 'sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace)'
    cpu_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, cpu_query)
    
    # Memory Usage by namespace
    mem_query: str = 'sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace)'
    mem_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, mem_query)
    
    # Pod count by namespace
    pod_query: str = 'count(kube_pod_info) by (namespace)'
    pod_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, pod_query)
    
    print(f"{'Namespace':<25} {'Pods':<8} {'CPU Usage':<20} {'Memory Usage':<20}")
    print("─" * 73)
    
    # Combine results
    namespaces: Dict[str, Dict[str, Any]] = {}
    
    for cpu_result in cpu_results:
        ns: str = cpu_result['metric'].get('namespace', 'unknown')
        namespaces[ns] = {'cpu': float(cpu_result['value'][1]), 'memory': 0.0, 'pods': 0}
    
    for mem_result in mem_results:
        ns = mem_result['metric'].get('namespace', 'unknown')
        if ns in namespaces:
            namespaces[ns]['memory'] = float(mem_result['value'][1])
        else:
            namespaces[ns] = {'cpu': 0.0, 'memory': float(mem_result['value'][1]), 'pods': 0}
    
    for pod_result in pod_results:
        ns = pod_result['metric'].get('namespace', 'unknown')
        if ns in namespaces:
            namespaces[ns]['pods'] = int(float(pod_result['value'][1]))
    
    # Sort by CPU usage
    sorted_namespaces: List[tuple] = sorted(namespaces.items(), key=lambda x: x[1]['cpu'], reverse=True)
    
    for ns, data in sorted_namespaces:
        cpu_str: str = format_cpu(data['cpu'])
        mem_str: str = format_bytes(data['memory'])
        pods: int = data['pods']
        
        print(f"{ns:<25} {pods:<8} {cpu_str:<20} {mem_str:<20}")


def show_pod_resources(prometheus_url: str, limit: int = 10) -> None:
    """Show top pods by CPU and memory usage"""
    print(f"\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"🔝 TOP {limit} PODS BY RESOURCE USAGE")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    # Top pods by CPU
    cpu_query: str = f'topk({limit}, sum(rate(container_cpu_usage_seconds_total{{container!="",container!="POD"}}[5m])) by (namespace, pod))'
    cpu_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, cpu_query)
    
    print("Top Pods by CPU:")
    print(f"{'Namespace/Pod':<50} {'CPU Usage':<20}")
    print("─" * 70)
    
    for result in cpu_results:
        namespace: str = result['metric'].get('namespace', 'unknown')
        pod: str = result['metric'].get('pod', 'unknown')
        cpu_value: float = float(result['value'][1])
        
        pod_name: str = f"{namespace}/{pod}"
        cpu_str: str = format_cpu(cpu_value)
        
        print(f"{pod_name:<50} {cpu_str:<20}")
    
    # Top pods by Memory
    mem_query: str = f'topk({limit}, sum(container_memory_usage_bytes{{container!="",container!="POD"}}) by (namespace, pod))'
    mem_results: List[Dict[str, Any]] = query_prometheus(prometheus_url, mem_query)
    
    print(f"\nTop Pods by Memory:")
    print(f"{'Namespace/Pod':<50} {'Memory Usage':<20}")
    print("─" * 70)
    
    for result in mem_results:
        namespace = result['metric'].get('namespace', 'unknown')
        pod = result['metric'].get('pod', 'unknown')
        mem_value: float = float(result['value'][1])
        
        pod_name = f"{namespace}/{pod}"
        mem_str: str = format_bytes(mem_value)
        
        print(f"{pod_name:<50} {mem_str:<20}")


def show_summary(prometheus_url: str) -> None:
    """Show cluster resource summary"""
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📊 CLUSTER RESOURCE SUMMARY")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    # Total CPU usage
    total_cpu_query: str = 'sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m]))'
    total_cpu: List[Dict[str, Any]] = query_prometheus(prometheus_url, total_cpu_query)
    
    # Total Memory usage
    total_mem_query: str = 'sum(container_memory_usage_bytes{container!="",container!="POD"})'
    total_mem: List[Dict[str, Any]] = query_prometheus(prometheus_url, total_mem_query)
    
    # Total pods
    total_pods_query: str = 'count(kube_pod_info)'
    total_pods: List[Dict[str, Any]] = query_prometheus(prometheus_url, total_pods_query)
    
    # Total nodes
    total_nodes_query: str = 'count(kube_node_info)'
    total_nodes: List[Dict[str, Any]] = query_prometheus(prometheus_url, total_nodes_query)
    
    if total_cpu and total_mem and total_pods and total_nodes:
        cpu_val: float = float(total_cpu[0]['value'][1])
        mem_val: float = float(total_mem[0]['value'][1])
        pods_val: int = int(float(total_pods[0]['value'][1]))
        nodes_val: int = int(float(total_nodes[0]['value'][1]))
        
        print(f"Total Nodes:        {nodes_val}")
        print(f"Total Pods:         {pods_val}")
        print(f"Total CPU Usage:    {format_cpu(cpu_val)}")
        print(f"Total Memory Usage: {format_bytes(mem_val)}")


def main() -> None:
    """Main function"""
    print_header()
    
    # Prometheus URL (assumes port-forward is running)
    prometheus_url: str = "http://localhost:9090"
    
    print(f"🔍 Connecting to Prometheus at {prometheus_url}")
    print()
    
    # Check connection
    if not check_prometheus_connection(prometheus_url):
        sys.exit(1)
    
    print()
    
    # Show cluster summary
    show_summary(prometheus_url)
    
    # Show node resources
    show_node_resources(prometheus_url)
    
    # Show namespace resources
    show_namespace_resources(prometheus_url)
    
    # Show top pods
    show_pod_resources(prometheus_url, limit=10)
    
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("💡 TIP: View detailed dashboards in Grafana:")
    print("   http://localhost:3000")
    print()
    print("   Available Dashboards:")
    print("   • Kubernetes Cluster Overview")
    print("   • Kubernetes Resource Monitoring - CPU & Memory")
    print("   • Pod Resource Details - CPU & Memory")
    print("   • Namespace Resource Monitoring")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()


if __name__ == "__main__":
    main()

