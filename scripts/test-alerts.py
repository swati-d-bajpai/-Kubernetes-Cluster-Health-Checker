#!/usr/bin/env python3
"""
Test Prometheus Alerts
This script checks if Prometheus alerts are configured and working
"""

from typing import Any, Dict, List
import requests
import json
import sys
from datetime import datetime

# Type ignore for requests
requests  # type: ignore


def print_header() -> None:
    """Print script header"""
    print("╔══════════════════════════════════════════════════════════════════════════╗")
    print("║                                                                          ║")
    print("║                    TEST PROMETHEUS ALERTS                                ║")
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


def get_alert_rules(prometheus_url: str) -> List[Dict[str, Any]]:
    """Get all configured alert rules"""
    try:
        response: Any = requests.get(f"{prometheus_url}/api/v1/rules", timeout=5)
        if response.status_code == 200:
            data: Dict[str, Any] = response.json()
            return data.get('data', {}).get('groups', [])
        else:
            print(f"❌ Failed to get alert rules: HTTP {response.status_code}")
            return []
    except requests.exceptions.RequestException as e:
        print(f"❌ Error getting alert rules: {e}")
        return []


def get_active_alerts(prometheus_url: str) -> List[Dict[str, Any]]:
    """Get currently firing alerts"""
    try:
        response: Any = requests.get(f"{prometheus_url}/api/v1/alerts", timeout=5)
        if response.status_code == 200:
            data: Dict[str, Any] = response.json()
            return data.get('data', {}).get('alerts', [])
        else:
            print(f"❌ Failed to get active alerts: HTTP {response.status_code}")
            return []
    except requests.exceptions.RequestException as e:
        print(f"❌ Error getting active alerts: {e}")
        return []


def display_alert_rules(rules: List[Dict[str, Any]]) -> None:
    """Display configured alert rules"""
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 CONFIGURED ALERT RULES")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    total_rules: int = 0
    
    for group in rules:
        group_name: str = group.get('name', 'Unknown')
        group_rules: List[Dict[str, Any]] = group.get('rules', [])
        
        # Filter only alerting rules
        alert_rules: List[Dict[str, Any]] = [r for r in group_rules if r.get('type') == 'alerting']
        
        if alert_rules:
            print(f"\n📁 Group: {group_name}")
            print(f"   Rules: {len(alert_rules)}")
            print()
            
            for rule in alert_rules:
                alert_name: str = rule.get('name', 'Unknown')
                severity: str = rule.get('labels', {}).get('severity', 'unknown')
                category: str = rule.get('labels', {}).get('category', 'unknown')
                
                # Color code by severity
                if severity == 'critical':
                    severity_icon: str = "🔴"
                elif severity == 'warning':
                    severity_icon = "🟡"
                else:
                    severity_icon = "⚪"
                
                print(f"   {severity_icon} {alert_name}")
                print(f"      Severity: {severity} | Category: {category}")
                
                total_rules += 1
    
    print()
    print(f"✅ Total Alert Rules: {total_rules}")


def display_active_alerts(alerts: List[Dict[str, Any]]) -> None:
    """Display currently firing alerts"""
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🔔 ACTIVE ALERTS")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    if not alerts:
        print("✅ No alerts currently firing - All systems healthy!")
        return
    
    # Group alerts by severity
    critical_alerts: List[Dict[str, Any]] = []
    warning_alerts: List[Dict[str, Any]] = []
    other_alerts: List[Dict[str, Any]] = []
    
    for alert in alerts:
        severity: str = alert.get('labels', {}).get('severity', 'unknown')
        if severity == 'critical':
            critical_alerts.append(alert)
        elif severity == 'warning':
            warning_alerts.append(alert)
        else:
            other_alerts.append(alert)
    
    # Display critical alerts
    if critical_alerts:
        print("🔴 CRITICAL ALERTS:")
        for alert in critical_alerts:
            alert_name: str = alert.get('labels', {}).get('alertname', 'Unknown')
            summary: str = alert.get('annotations', {}).get('summary', 'No summary')
            state: str = alert.get('state', 'unknown')
            print(f"   • {alert_name} ({state})")
            print(f"     {summary}")
        print()
    
    # Display warning alerts
    if warning_alerts:
        print("🟡 WARNING ALERTS:")
        for alert in warning_alerts:
            alert_name = alert.get('labels', {}).get('alertname', 'Unknown')
            summary = alert.get('annotations', {}).get('summary', 'No summary')
            state = alert.get('state', 'unknown')
            print(f"   • {alert_name} ({state})")
            print(f"     {summary}")
        print()
    
    # Display other alerts
    if other_alerts:
        print("⚪ OTHER ALERTS:")
        for alert in other_alerts:
            alert_name = alert.get('labels', {}).get('alertname', 'Unknown')
            summary = alert.get('annotations', {}).get('summary', 'No summary')
            state = alert.get('state', 'unknown')
            print(f"   • {alert_name} ({state})")
            print(f"     {summary}")
        print()
    
    print(f"Total Active Alerts: {len(alerts)}")
    print(f"  Critical: {len(critical_alerts)}")
    print(f"  Warning: {len(warning_alerts)}")
    print(f"  Other: {len(other_alerts)}")


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
    
    # Get and display alert rules
    print("📥 Fetching alert rules...")
    rules: List[Dict[str, Any]] = get_alert_rules(prometheus_url)
    
    if rules:
        display_alert_rules(rules)
    else:
        print("⚠️  No alert rules found")
    
    # Get and display active alerts
    print("\n📥 Fetching active alerts...")
    alerts: List[Dict[str, Any]] = get_active_alerts(prometheus_url)
    display_active_alerts(alerts)
    
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("💡 TIP: View alerts in Prometheus UI:")
    print("   http://localhost:9090/alerts")
    print()
    print("💡 View alerts in AlertManager:")
    print("   http://localhost:9093")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()


if __name__ == "__main__":
    main()

