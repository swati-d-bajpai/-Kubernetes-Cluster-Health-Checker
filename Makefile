# Makefile for Kubernetes Cluster Health Checker
# Simplifies common Docker and development tasks

.PHONY: help build run stop clean logs test lint format

# Variables
IMAGE_NAME := k8s-health-checker
IMAGE_TAG := latest
CONTAINER_NAME := health-checker
COMPOSE_FILE := docker-compose.yml

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

## help: Show this help message
help:
	@echo "$(GREEN)Kubernetes Cluster Health Checker - Makefile Commands$(NC)"
	@echo ""
	@echo "$(YELLOW)Docker Commands:$(NC)"
	@echo "  make build          - Build Docker image"
	@echo "  make run            - Run container"
	@echo "  make stop           - Stop container"
	@echo "  make restart        - Restart container"
	@echo "  make logs           - View container logs"
	@echo "  make shell          - Open shell in container"
	@echo "  make clean          - Remove container and image"
	@echo ""
	@echo "$(YELLOW)Docker Compose Commands:$(NC)"
	@echo "  make up             - Start all services"
	@echo "  make down           - Stop all services"
	@echo "  make ps             - List running services"
	@echo "  make logs-all       - View all service logs"
	@echo "  make restart-all    - Restart all services"
	@echo ""
	@echo "$(YELLOW)Development Commands:$(NC)"
	@echo "  make test           - Run tests"
	@echo "  make lint           - Run linter"
	@echo "  make format         - Format code"
	@echo "  make venv           - Create virtual environment"
	@echo "  make install        - Install dependencies"
	@echo ""
	@echo "$(YELLOW)Kubernetes Commands:$(NC)"
	@echo "  make k8s-setup      - Setup Minikube cluster"
	@echo "  make k8s-status     - Check cluster status"
	@echo "  make k8s-clean      - Delete Minikube cluster"
	@echo ""
	@echo "$(YELLOW)Monitoring Commands:$(NC)"
	@echo "  make monitor        - Start monitoring stack"
	@echo "  make port-forward   - Start port forwards"
	@echo "  make dashboards     - Open Grafana dashboards"

## build: Build Docker image
build:
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "$(GREEN)✓ Image built successfully$(NC)"

## run: Run Docker container
run:
	@echo "$(GREEN)Running container...$(NC)"
	docker run -d \
		--name $(CONTAINER_NAME) \
		-v ~/.kube/config:/root/.kube/config:ro \
		-v $(PWD)/logs:/app/logs \
		--network host \
		$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "$(GREEN)✓ Container started$(NC)"

## stop: Stop Docker container
stop:
	@echo "$(YELLOW)Stopping container...$(NC)"
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	@echo "$(GREEN)✓ Container stopped$(NC)"

## restart: Restart Docker container
restart: stop run
	@echo "$(GREEN)✓ Container restarted$(NC)"

## logs: View container logs
logs:
	@echo "$(GREEN)Viewing logs (Ctrl+C to exit)...$(NC)"
	docker logs -f $(CONTAINER_NAME)

## shell: Open shell in container
shell:
	@echo "$(GREEN)Opening shell in container...$(NC)"
	docker exec -it $(CONTAINER_NAME) /bin/bash

## clean: Remove container and image
clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

## up: Start all Docker Compose services
up:
	@echo "$(GREEN)Starting all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ All services started$(NC)"
	@echo ""
	@echo "$(YELLOW)Access services at:$(NC)"
	@echo "  Prometheus:   http://localhost:9090"
	@echo "  Grafana:      http://localhost:3000 (admin/admin)"
	@echo "  AlertManager: http://localhost:9093"

## down: Stop all Docker Compose services
down:
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ All services stopped$(NC)"

## ps: List running Docker Compose services
ps:
	@echo "$(GREEN)Running services:$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

## logs-all: View all service logs
logs-all:
	@echo "$(GREEN)Viewing all logs (Ctrl+C to exit)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) logs -f

## restart-all: Restart all Docker Compose services
restart-all:
	@echo "$(YELLOW)Restarting all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)✓ All services restarted$(NC)"

## test: Run tests
test:
	@echo "$(GREEN)Running tests...$(NC)"
	@if [ -d "venv" ]; then \
		. venv/bin/activate && python -m pytest tests/ -v; \
	else \
		echo "$(RED)Virtual environment not found. Run 'make venv' first.$(NC)"; \
	fi

## lint: Run linter
lint:
	@echo "$(GREEN)Running linter...$(NC)"
	@if [ -d "venv" ]; then \
		. venv/bin/activate && \
		pylint src/ scripts/*.py || true && \
		mypy src/ scripts/*.py || true; \
	else \
		echo "$(RED)Virtual environment not found. Run 'make venv' first.$(NC)"; \
	fi

## format: Format code
format:
	@echo "$(GREEN)Formatting code...$(NC)"
	@if [ -d "venv" ]; then \
		. venv/bin/activate && \
		black src/ scripts/*.py && \
		isort src/ scripts/*.py; \
	else \
		echo "$(RED)Virtual environment not found. Run 'make venv' first.$(NC)"; \
	fi

## venv: Create virtual environment
venv:
	@echo "$(GREEN)Creating virtual environment...$(NC)"
	python3 -m venv venv
	@echo "$(GREEN)✓ Virtual environment created$(NC)"
	@echo "$(YELLOW)Activate with: source venv/bin/activate$(NC)"

## install: Install dependencies
install:
	@echo "$(GREEN)Installing dependencies...$(NC)"
	@if [ -d "venv" ]; then \
		. venv/bin/activate && pip install -r requirements.txt; \
	else \
		echo "$(RED)Virtual environment not found. Run 'make venv' first.$(NC)"; \
	fi

## k8s-setup: Setup Minikube cluster
k8s-setup:
	@echo "$(GREEN)Setting up Minikube cluster...$(NC)"
	./scripts/setup-minikube.sh
	@echo "$(GREEN)✓ Cluster setup complete$(NC)"

## k8s-status: Check cluster status
k8s-status:
	@echo "$(GREEN)Checking cluster status...$(NC)"
	@echo ""
	@echo "$(YELLOW)Minikube Status:$(NC)"
	minikube status || true
	@echo ""
	@echo "$(YELLOW)Cluster Info:$(NC)"
	kubectl cluster-info || true
	@echo ""
	@echo "$(YELLOW)Nodes:$(NC)"
	kubectl get nodes || true
	@echo ""
	@echo "$(YELLOW)Pods in monitoring namespace:$(NC)"
	kubectl get pods -n monitoring || true

## k8s-clean: Delete Minikube cluster
k8s-clean:
	@echo "$(YELLOW)Deleting Minikube cluster...$(NC)"
	minikube delete
	@echo "$(GREEN)✓ Cluster deleted$(NC)"

## monitor: Start monitoring stack
monitor:
	@echo "$(GREEN)Starting monitoring stack...$(NC)"
	./scripts/configure-monitoring.sh
	@echo "$(GREEN)✓ Monitoring configured$(NC)"

## port-forward: Start port forwards
port-forward:
	@echo "$(GREEN)Starting port forwards...$(NC)"
	./scripts/start-port-forwards.sh
	@echo "$(GREEN)✓ Port forwards started$(NC)"
	@echo ""
	@echo "$(YELLOW)Access services at:$(NC)"
	@echo "  Prometheus:   http://localhost:9090"
	@echo "  Grafana:      http://localhost:3000"
	@echo "  AlertManager: http://localhost:9093"

## dashboards: Open Grafana dashboards
dashboards:
	@echo "$(GREEN)Opening Grafana...$(NC)"
	open http://localhost:3000 || xdg-open http://localhost:3000 || echo "Open http://localhost:3000 in your browser"

## health-check: Run health check
health-check:
	@echo "$(GREEN)Running health check...$(NC)"
	@if [ -d "venv" ]; then \
		. venv/bin/activate && python3 scripts/check-health.py; \
	else \
		echo "$(RED)Virtual environment not found. Run 'make venv' first.$(NC)"; \
	fi

## resource-usage: Show resource usage
resource-usage:
	@echo "$(GREEN)Showing resource usage...$(NC)"
	@if [ -d "venv" ]; then \
		. venv/bin/activate && python3 scripts/show-resource-usage.py; \
	else \
		echo "$(RED)Virtual environment not found. Run 'make venv' first.$(NC)"; \
	fi

## all: Build and run everything
all: build up
	@echo "$(GREEN)✓ Everything is running!$(NC)"

## dev: Setup development environment
dev: venv install
	@echo "$(GREEN)✓ Development environment ready!$(NC)"
	@echo "$(YELLOW)Activate with: source venv/bin/activate$(NC)"

## prod: Build and run in production mode
prod: build
	@echo "$(GREEN)Building for production...$(NC)"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) --target production .
	@echo "$(GREEN)✓ Production build complete$(NC)"

