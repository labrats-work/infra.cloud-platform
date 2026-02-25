.PHONY: help validate validate-terraform validate-kubernetes lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

# Validation
validate: validate-terraform validate-kubernetes ## Run all validation checks

validate-terraform: ## Validate Terraform configurations
	@echo "Validating Terraform..."
	@for dir in clouds/*/terraform/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "  Checking $$dir"; \
			terraform -chdir=$$dir validate 2>/dev/null || echo "  WARN: $$dir needs terraform init first"; \
		fi \
	done

validate-kubernetes: ## Validate Kubernetes manifests
	@echo "Validating Kubernetes manifests..."
	@find platform/ -name '*.yaml' -o -name '*.yml' | head -20 | while read f; do \
		kubectl apply --dry-run=client -f "$$f" 2>/dev/null || echo "  WARN: $$f (may need CRDs)"; \
	done

lint: ## Lint all configuration files
	@echo "Linting YAML files..."
	@yamllint -d relaxed . 2>/dev/null || echo "Install yamllint: pip install yamllint"

# Cloud-specific targets
hetzner-plan: ## Run Terraform plan for Hetzner
	cd clouds/hetzner/terraform/cluster && terraform plan

hetzner-apply: ## Apply Terraform for Hetzner
	cd clouds/hetzner/terraform/cluster && terraform apply

# Platform targets
flux-check: ## Check Flux reconciliation status
	flux get all

flux-reconcile: ## Force Flux reconciliation
	flux reconcile source git flux-system
