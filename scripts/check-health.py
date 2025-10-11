#!/usr/bin/env python3
"""
Quick health check script for Kubernetes cluster

This script performs a comprehensive health check:
- Checks if all nodes are ready
- Checks if critical system pods are running
- Returns exit code 0 if healthy, 1 if issues found

Usage:
    python3 scripts/check-health.py
"""

from typing import Any, List
from kubernetes import client, config  # type: ignore
import sys

def check_nodes() -> bool:
    """Check if all nodes are ready"""
    v1: Any = client.CoreV1Api()
    nodes: Any = v1.list_node()

    all_ready: bool = True
    for node in nodes.items:
        for condition in node.status.conditions:
            if condition.type == "Ready":
                if condition.status != "True":
                    all_ready = False
                    print(f"❌ Node {node.metadata.name} is NOT ready")
                else:
                    print(f"✅ Node {node.metadata.name} is ready")

    return all_ready

def check_critical_pods() -> bool:
    """Check if critical system pods are running"""
    v1: Any = client.CoreV1Api()

    critical_namespaces: List[str] = ["kube-system", "monitoring"]
    all_healthy: bool = True

    for namespace in critical_namespaces:
        try:
            pods: Any = v1.list_namespaced_pod(namespace=namespace)

            for pod in pods.items:
                if pod.status.phase != "Running":
                    all_healthy = False
                    print(f"❌ Pod {pod.metadata.name} in {namespace} is {pod.status.phase}")
        except Exception as e:
            print(f"⚠️  Warning: Could not check namespace {namespace}: {e}")

    if all_healthy:
        print(f"✅ All critical pods are running")

    return all_healthy

def main() -> None:
    """Main health check function"""
    print("=" * 60)
    print("KUBERNETES CLUSTER HEALTH CHECK")
    print("=" * 60)

    # Load configuration
    try:
        config.load_kube_config()  # type: ignore
    except Exception as e:
        print(f"❌ Failed to load Kubernetes config: {e}")
        sys.exit(1)

    print("\n🔍 Checking Nodes...")
    nodes_ok: bool = check_nodes()

    print("\n🔍 Checking Critical Pods...")
    pods_ok: bool = check_critical_pods()

    print("\n" + "=" * 60)
    if nodes_ok and pods_ok:
        print("✅ CLUSTER IS HEALTHY")
        print("=" * 60)
        sys.exit(0)
    else:
        print("❌ CLUSTER HAS ISSUES")
        print("=" * 60)
        sys.exit(1)

if __name__ == "__main__":
    main()

