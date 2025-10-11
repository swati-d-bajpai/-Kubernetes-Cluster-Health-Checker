#!/usr/bin/env python3
"""
Get information about Kubernetes services

This script demonstrates how to:
- List services in a namespace
- Get service details (type, IP, ports)
- Display service endpoints
"""

from typing import Any
from kubernetes import client, config  # type: ignore

def main() -> None:
    """Main function to display service information"""
    config.load_kube_config()  # type: ignore
    v1: Any = client.CoreV1Api()

    print("=" * 60)
    print("KUBERNETES SERVICES")
    print("=" * 60)

    # Get services in monitoring namespace
    services: Any = v1.list_namespaced_service(namespace="monitoring")

    print(f"\n📊 Services in 'monitoring' namespace: {len(services.items)}\n")

    for svc in services.items:
        print(f"🔹 Service: {svc.metadata.name}")
        print(f"   Type: {svc.spec.type}")
        print(f"   Cluster IP: {svc.spec.cluster_ip}")

        if svc.spec.ports:
            print(f"   Ports:")
            for port in svc.spec.ports:
                port_name: str = port.name or 'unnamed'
                print(f"      • {port_name}: {port.port}/{port.protocol}")
        print()

    print("=" * 60)

if __name__ == "__main__":
    main()

