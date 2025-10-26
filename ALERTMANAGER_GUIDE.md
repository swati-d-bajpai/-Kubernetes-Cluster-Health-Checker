# AlertManager Guide - Kubernetes Cluster Health Checker

Complete guide to understanding and configuring AlertManager for Kubernetes monitoring.

---

## 📋 Table of Contents

1. [What is AlertManager?](#what-is-alertmanager)
2. [Why Use AlertManager?](#why-use-alertmanager)
3. [How AlertManager Works](#how-alertmanager-works)
4. [Configuration Examples](#configuration-examples)
5. [Accessing AlertManager](#accessing-alertmanager)
6. [Common Use Cases](#common-use-cases)
7. [Best Practices](#best-practices)

---

## 🔔 What is AlertManager?

AlertManager is the **notification engine** for Prometheus. While Prometheus detects problems, AlertManager handles:

- 📧 **Sending notifications** (Email, Slack, PagerDuty, etc.)
- 🔄 **Deduplicating alerts** (no spam!)
- 📦 **Grouping related alerts** (50 pods down = 1 notification)
- 🔕 **Silencing alerts** (during maintenance)
- 🚫 **Inhibiting dependent alerts** (hide symptoms, show root cause)
- 🎯 **Routing alerts** (critical → PagerDuty, warning → Slack)

---

## 🎯 Why Use AlertManager?

### Problem 1: Prometheus Can't Send Notifications

**Without AlertManager:**
```
Prometheus: "CPU is at 95%!" 
You: "Great, but how do I know?" 🤷
```

**With AlertManager:**
```
Prometheus: "CPU is at 95%!"
AlertManager: 
  → Sends email to ops-team@company.com
  → Posts to #alerts Slack channel
  → Pages on-call engineer via PagerDuty
You: "Got it! Investigating now." ✅
```

---

### Problem 2: Alert Spam

**Without AlertManager:**
```
10:00 - Alert: Pod CrashLooping
10:01 - Alert: Pod CrashLooping (duplicate)
10:02 - Alert: Pod CrashLooping (duplicate)
...
10:59 - Alert: Pod CrashLooping (60th duplicate!)

Result: 60 notifications for 1 problem! 😱
```

**With AlertManager:**
```
10:00 - Alert: Pod CrashLooping
10:05 - Update: Still CrashLooping
10:10 - Update: Still CrashLooping

Result: 1 alert + periodic updates ✅
```

---

### Problem 3: Cascading Alerts

**Without AlertManager:**
```
Node goes down →
  ❌ NodeDown alert
  ❌ Pod1Down alert (because node is down)
  ❌ Pod2Down alert (because node is down)
  ❌ Pod3Down alert (because node is down)
  ... (50 pods)
  ❌ ServiceUnavailable alert (because pods are down)

Result: 52 alerts for 1 root cause! 😱
```

**With AlertManager (Inhibition):**
```
Node goes down →
  ✅ NodeDown alert (root cause)
  ⏸️  Pod alerts inhibited (dependent)
  ⏸️  Service alerts inhibited (dependent)

Result: 1 alert for the root cause! ✅
```

---

### Problem 4: Planned Maintenance

**Without AlertManager:**
```
You: "Upgrading nodes tonight, expect downtime"
11:00 PM - NodeDown alerts fire
11:00 PM - Team gets paged
Team: "Why are we getting woken up?!" 😡
```

**With AlertManager (Silencing):**
```
You: "Upgrading nodes tonight, expect downtime"
You: Silence NodeDown alerts for 2 hours
11:00 PM - NodeDown alerts fire
11:00 PM - AlertManager: "Silenced, not sending"
Team: Sleeps peacefully 😴
```

---

## 🏗️ How AlertManager Works

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        PROMETHEUS                            │
│                                                              │
│  1. Scrapes metrics from Kubernetes                          │
│  2. Evaluates alert rules every 15 seconds                   │
│  3. Fires alerts when conditions are met                     │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         │ HTTP POST /api/v1/alerts
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                      ALERTMANAGER                            │
│                                                              │
│  4. Receives alerts from Prometheus                          │
│  5. Deduplicates identical alerts                            │
│  6. Groups related alerts together                           │
│  7. Applies silencing rules                                  │
│  8. Applies inhibition rules                                 │
│  9. Routes to appropriate receivers                          │
└────────────────────────┬─────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┬──────────────┐
         │               │               │              │
         ▼               ▼               ▼              ▼
    ┌────────┐      ┌────────┐     ┌──────────┐   ┌─────────┐
    │ Email  │      │ Slack  │     │PagerDuty │   │ Webhook │
    └────────┘      └────────┘     └──────────┘   └─────────┘
```

---

### Alert Lifecycle

```
1. INACTIVE → Alert rule exists but condition not met
              Example: CPU < 90%

2. PENDING → Condition met, waiting for duration
             Example: CPU > 90% for 30 seconds
             
3. FIRING → Duration exceeded, alert sent to AlertManager
            Example: CPU > 90% for 2 minutes

4. RESOLVED → Condition no longer met
              Example: CPU back to 60%
```

---

## ⚙️ Configuration Examples

### Example 1: Email Notifications

```yaml
# alertmanager.yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@company.com'
  smtp_auth_username: 'alerts@company.com'
  smtp_auth_password: 'your-password'

route:
  receiver: 'email-team'
  group_by: ['alertname', 'namespace']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

receivers:
  - name: 'email-team'
    email_configs:
      - to: 'ops-team@company.com'
        headers:
          Subject: '🚨 Alert: {{ .GroupLabels.alertname }}'
```

**Result:**
- Alerts sent to ops-team@company.com
- Grouped by alert name and namespace
- Wait 30s before sending first alert
- Send updates every 5 minutes
- Repeat every 4 hours if still firing

---

### Example 2: Slack Notifications

```yaml
# alertmanager.yaml
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'

route:
  receiver: 'slack-alerts'
  group_by: ['severity']

receivers:
  - name: 'slack-alerts'
    slack_configs:
      - channel: '#alerts'
        title: '🚨 {{ .GroupLabels.alertname }}'
        text: |
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
        color: '{{ if eq .GroupLabels.severity "critical" }}danger{{ else }}warning{{ end }}'
```

**Result:**
- Alerts posted to #alerts Slack channel
- Color-coded: red for critical, yellow for warning
- Includes alert details and descriptions

---

### Example 3: Routing by Severity

```yaml
# alertmanager.yaml
route:
  receiver: 'default'
  group_by: ['alertname']
  
  routes:
    # Critical alerts → PagerDuty
    - match:
        severity: critical
      receiver: 'pagerduty'
      group_wait: 10s
      repeat_interval: 1h
    
    # Warning alerts → Slack
    - match:
        severity: warning
      receiver: 'slack'
      group_wait: 30s
      repeat_interval: 4h
    
    # Info alerts → Email
    - match:
        severity: info
      receiver: 'email'
      group_wait: 5m
      repeat_interval: 24h

receivers:
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'your-pagerduty-key'
  
  - name: 'slack'
    slack_configs:
      - channel: '#alerts'
        api_url: 'your-slack-webhook'
  
  - name: 'email'
    email_configs:
      - to: 'team@company.com'
```

**Result:**
- 🔴 Critical → PagerDuty (immediate page)
- 🟡 Warning → Slack (team notification)
- 🟢 Info → Email (daily digest)

---

### Example 4: Alert Inhibition

```yaml
# alertmanager.yaml
inhibit_rules:
  # If node is down, don't alert about pods on that node
  - source_match:
      alertname: 'NodeDown'
    target_match:
      alertname: 'PodDown'
    equal: ['node']
  
  # If namespace has issues, don't alert about individual pods
  - source_match:
      alertname: 'NamespaceDown'
    target_match_re:
      alertname: 'Pod.*'
    equal: ['namespace']
```

**Result:**
- NodeDown alert fires → PodDown alerts on that node are suppressed
- NamespaceDown alert fires → All pod alerts in that namespace are suppressed

---

### Example 5: Alert Grouping

```yaml
# alertmanager.yaml
route:
  receiver: 'default'
  
  # Group by namespace and severity
  group_by: ['namespace', 'severity']
  
  # Wait 30s to collect alerts before sending
  group_wait: 30s
  
  # Send updates every 5 minutes
  group_interval: 5m
  
  # Repeat notification every 4 hours
  repeat_interval: 4h
```

**Result:**
```
Instead of:
  ❌ Alert: pod-1 high CPU in production
  ❌ Alert: pod-2 high CPU in production
  ❌ Alert: pod-3 high CPU in production

You get:
  ✅ Alert: 3 pods have high CPU in production namespace
```

---

## 🌐 Accessing AlertManager

### Start Port Forward

```bash
# Option 1: Use our script
./scripts/start-port-forwards.sh

# Option 2: Manual port forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

### Access Web UI

```bash
# Open in browser
open http://localhost:9093

# Or visit manually
http://localhost:9093
```

### Web UI Features

1. **Alerts Tab** - View all active alerts
2. **Silences Tab** - Create/view/delete silences
3. **Status Tab** - View AlertManager configuration

---

## 💡 Common Use Cases

### Use Case 1: Silence Alerts During Maintenance

**Scenario:** Upgrading Kubernetes nodes, expect downtime for 2 hours

**Steps:**
1. Open AlertManager UI: http://localhost:9093
2. Click **Silences** tab
3. Click **New Silence**
4. Fill in:
   - **Matchers:** `alertname=NodeDown`
   - **Duration:** 2h
   - **Creator:** your-name
   - **Comment:** "Planned node upgrade"
5. Click **Create**

**Result:** NodeDown alerts won't be sent for 2 hours

---

### Use Case 2: View Active Alerts

**Steps:**
1. Open AlertManager UI: http://localhost:9093
2. Click **Alerts** tab
3. View all firing alerts
4. Filter by:
   - Alert name
   - Severity
   - Namespace

---

### Use Case 3: Test Alert Notifications

```bash
# Send test alert to AlertManager
curl -X POST http://localhost:9093/api/v1/alerts -d '[
  {
    "labels": {
      "alertname": "TestAlert",
      "severity": "warning"
    },
    "annotations": {
      "summary": "This is a test alert"
    }
  }
]'
```

---

## 📊 Best Practices

### 1. Use Severity Levels

```yaml
# In Prometheus alert rules
- alert: HighCPU
  expr: cpu_usage > 90
  labels:
    severity: warning
  
- alert: CriticalCPU
  expr: cpu_usage > 95
  labels:
    severity: critical
```

### 2. Add Meaningful Annotations

```yaml
- alert: PodCrashLooping
  annotations:
    summary: "Pod {{ $labels.pod }} is crash looping"
    description: "Pod has restarted {{ $value }} times in the last 5 minutes"
    runbook_url: "https://wiki.company.com/runbooks/pod-crash"
```

### 3. Group Related Alerts

```yaml
route:
  group_by: ['namespace', 'alertname']
```

### 4. Set Appropriate Intervals

```yaml
route:
  group_wait: 30s        # Wait to collect similar alerts
  group_interval: 5m     # Send updates every 5 min
  repeat_interval: 4h    # Repeat every 4 hours
```

### 5. Use Inhibition for Root Causes

```yaml
inhibit_rules:
  - source_match:
      alertname: 'NodeDown'
    target_match_re:
      alertname: 'Pod.*|Service.*'
    equal: ['node']
```

---

## 🔍 Troubleshooting

### Issue: Alerts not being sent

**Check:**
```bash
# View AlertManager logs
kubectl logs -n monitoring alertmanager-prometheus-kube-prometheus-alertmanager-0

# Check AlertManager config
kubectl get secret alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring -o yaml
```

### Issue: Too many notifications

**Solution:** Increase `repeat_interval`
```yaml
route:
  repeat_interval: 12h  # Instead of 4h
```

### Issue: Missing important alerts

**Solution:** Check silences
```bash
# View active silences in UI
http://localhost:9093/#/silences
```

---

## 📚 Additional Resources

- **Official Docs:** https://prometheus.io/docs/alerting/latest/alertmanager/
- **Configuration:** https://prometheus.io/docs/alerting/latest/configuration/
- **MONITORING_GUIDE.md** - Our monitoring setup
- **TROUBLESHOOTING.md** - Common issues

---

**AlertManager is essential for production-grade monitoring!** 🔔✅

