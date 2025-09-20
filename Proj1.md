Project Title: K8s Cluster Health Checker and Auto-Healing


Problem Statement
In many organizations, managing Kubernetes clusters manually requires constant monitoring, troubleshooting, and intervention to maintain high availability. This is especially challenging for small DevOps teams managing large-scale clusters, as frequent manual tasks can consume time and lead to downtime. An automated health checker and self-healing tool can help monitor the state of Kubernetes clusters, detect and fix common issues (e.g., failed pods or unresponsive nodes), and ensure high availability with minimal manual intervention.

Project Goals
1. Develop an automated health monitoring system for Kubernetes clusters, focusing on key metrics like node health, pod statuses, and resource utilization.
2. Implement self-healing actions that restart failed pods, reschedule workloads, and, if necessary, trigger scaling events to balance workloads.
3. Provide real-time alerts and notifications to inform the team of critical issues that may require manual intervention.
4. Create a web dashboard to display real-time health status, historical data, and auto-healing logs for transparency and traceability.


Tools Used
- Programming Languages: Python (for scripting and initial data processing)
- Kubernetes API: For interacting with and managing Kubernetes resources
- Prometheus: For monitoring and collecting metrics from the Kubernetes cluster
- Grafana: For visualizing metrics and health status on a real-time dashboard
- Alertmanager (Prometheus): For sending alerts to Slack or other communication tools
- Slack API: For notifications to DevOps teams
- Docker: To containerize the application and deploy it as a microservice


Project Sprints:

Each sprint has a 20-hour workload, organized into specific tasks to ensure consistent progress.

 Sprint 1: Project Setup and Kubernetes Cluster Access
- Tasks:
  - Define project structure and initialize the repository.
  - Set up access to the Kubernetes cluster.
  - Configure basic API access to interact with Kubernetes resources (nodes, pods, services).
  - Install and configure Prometheus for Kubernetes to monitor cluster metrics.
- Goal: Establish a foundation for the project by setting up the necessary environment, tools, and access to Kubernetes resources.

 Sprint 2: Health Monitoring Module (Node & Pod Checks)
- Tasks:
  - Develop a module to monitor the health of nodes and pods using the Kubernetes API.
  - Set up Prometheus metrics collection for node and pod statuses (e.g., CPU, memory usage, pod readiness).
  - Begin integrating Prometheus with Grafana to visualize key metrics.
  - Implement initial threshold-based alerts for critical health issues using Alertmanager.
- Goal: Enable basic health checks on nodes and pods and set up alerts for critical issues.



 Sprint 3: Self-Healing Mechanisms (Pod Recovery)
- Tasks:
  - Implement pod restart and rescheduling based on health checks (e.g., if a pod is unresponsive or has failed).
  - Add automated resource cleanup for pods in "CrashLoopBackOff" or "Evicted" states.
  - Test self-healing actions in a staging environment.
  - Log each action for auditing and reporting.
- Goal: Automate pod recovery processes and ensure that self-healing actions are logged for transparency.



 Sprint 4: Advanced Self-Healing (Node Scaling & Resource Balancing)
- Tasks:
  - Implement automatic node scaling (up/down) based on resource utilization.
  - Configure horizontal pod autoscaling for workloads with high resource demands.
  - Set up resource balancing by redistributing pods across nodes to optimize cluster usage.
  - Test these features under simulated load to ensure reliability.
- Goal: Ensure the system can scale and balance resources automatically, optimizing cluster performance and cost.


 Sprint 5: Alerting and Notification System Integration
- Tasks:
  - Integrate Slack or Teams API for real-time notifications on critical issues or auto-healing actions.
  - Configure Alertmanager with customizable alerting rules for different severity levels.
  - Test alerts and notifications to ensure that DevOps teams receive timely updates.
  - Create documentation for setting up and managing alerts.
- Goal: Implement a comprehensive alerting and notification system to keep the team informed of critical events and actions.



 Sprint 6: Web Dashboard and Project Documentation
  - Tasks:
  - Develop a web dashboard (using Grafana or a custom interface) to display health metrics, self-healing actions, and historical data.
  - Integrate Prometheus metrics and alert logs into the dashboard.
  - Create user documentation, including setup, usage, and troubleshooting guides.
  - Conduct final testing and gather feedback for potential improvements.
- Goal: Deliver a user-friendly dashboard for monitoring cluster health and document the project for deployment in real-world environments.



 Summary of Deliverables by End of Project
- Automated Health Monitoring Tool for Kubernetes clusters
- Self-Healing Mechanisms for both pod and node recovery
- Real-Time Alerting and Notifications through Slack/Teams
- Web Dashboard for real-time and historical monitoring
- Comprehensive Documentation for setup, usage, and troubleshooting

Evaluation Criteria for Deliverables, Presentation and Viva:
Documentation 15.00%
Implementation 75.00%
Cost Optimization 10.00%
