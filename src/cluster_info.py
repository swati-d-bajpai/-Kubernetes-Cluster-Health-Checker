#!/usr/bin/env python3
"""
Simple script to get basic Kubernetes cluster information

This script demonstrates how to:
- Connect to a Kubernetes cluster
- Get cluster version information
- List nodes and their resources
- List all namespaces
"""

from typing import Any
from kubernetes import client, config  # type: ignore

def main() -> None:
    """Main function to display cluster information"""
    # Load Kubernetes configuration from ~/.kube/config
    config.load_kube_config()  # type: ignore

    # Create API client
    v1: Any = client.CoreV1Api()

    print("=" * 60)
    print("KUBERNETES CLUSTER INFORMATION")
    print("=" * 60)

    # Get cluster version
    version_api: Any = client.VersionApi()
    version_info: Any = version_api.get_code()
    print(f"\n📌 Kubernetes Version: {version_info.git_version}")
    print(f"📌 Platform: {version_info.platform}")

    # Get nodes
    print("\n" + "=" * 60)
    print("NODES")
    print("=" * 60)

    nodes: Any = v1.list_node()
    for node in nodes.items:
        print(f"\n✅ Node: {node.metadata.name}")

        # Check if node is ready
        for condition in node.status.conditions:
            if condition.type == "Ready":
                print(f"   Status: {condition.type}")
                print(f"   Ready: {condition.status}")

        # Get node resources
        capacity: Any = node.status.capacity
        print(f"   CPU: {capacity.get('cpu')}")
        print(f"   Memory: {capacity.get('memory')}")

    # Get namespaces
    print("\n" + "=" * 60)
    print("NAMESPACES")
    print("=" * 60)

    namespaces: Any = v1.list_namespace()
    print(f"\nTotal Namespaces: {len(namespaces.items)}\n")
    for ns in namespaces.items:
        print(f"  • {ns.metadata.name}")

    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()

