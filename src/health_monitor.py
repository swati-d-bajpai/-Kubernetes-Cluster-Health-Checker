#!/usr/bin/env python3
"""
Simple health monitoring script for Kubernetes pods

This script demonstrates how to:
- Get all pods across all namespaces
- Count pods by status
- Display detailed pod information
- Check container readiness
"""

from typing import Any, Dict
from kubernetes import client, config  # type: ignore

def main() -> None:
    """Main function to monitor pod health"""
    # Load Kubernetes configuration
    config.load_kube_config()  # type: ignore
    v1: Any = client.CoreV1Api()

    print("=" * 60)
    print("POD HEALTH MONITOR")
    print("=" * 60)

    # Get all pods across all namespaces
    pods: Any = v1.list_pod_for_all_namespaces()

    # Count pods by status
    status_count: Dict[str, int] = {}
    for pod in pods.items:
        phase: str = pod.status.phase
        status_count[phase] = status_count.get(phase, 0) + 1

    # Display summary
    print(f"\n📊 Total Pods: {len(pods.items)}")
    print("\n📈 Pod Status Summary:")
    for status, count in status_count.items():
        emoji = "✅" if status == "Running" else "⚠️"
        print(f"   {emoji} {status}: {count}")

    # Show pods in monitoring namespace
    print("\n" + "=" * 60)
    print("MONITORING NAMESPACE PODS")
    print("=" * 60)

    monitoring_pods: Any = v1.list_namespaced_pod(namespace="monitoring")
    for pod in monitoring_pods.items:
        status: str = pod.status.phase
        emoji: str = "✅" if status == "Running" else "❌"

        # Get container statuses
        ready_containers: int = 0
        total_containers: int = 0
        if pod.status.container_statuses:
            total_containers = len(pod.status.container_statuses)
            ready_containers = sum(1 for c in pod.status.container_statuses if c.ready)

        print(f"\n{emoji} {pod.metadata.name}")
        print(f"   Status: {status}")
        print(f"   Containers: {ready_containers}/{total_containers} ready")
        print(f"   Node: {pod.spec.node_name}")

    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()

