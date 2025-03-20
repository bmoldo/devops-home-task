
ENV=
PLAN_OPTS=
APPLY_OPTS=
TF_DIR=terraform/environments/$(ENV)
CONFIG_FILE=terraform/config/$(ENV).tfvars
PLANFILE=terraform/plans/$(ENV).tfplan

# Create necessary directories
init:
	mkdir -p terraform/plans
	mkdir -p terraform/config

# Initialize Terraform for environment
init-env:
	cd $(TF_DIR) && terraform init

# Plan changes
plan: init
	mkdir -p $(shell dirname $(PLANFILE))
	cd $(TF_DIR) && \
	terraform get && \
	terraform plan -out=$(shell pwd)/$(PLANFILE) -var-file=$(shell pwd)/$(CONFIG_FILE) -compact-warnings $(PLAN_OPTS)

# Apply changes
apply: 
	cd $(TF_DIR) && \
	terraform apply -compact-warnings $(APPLY_OPTS) $(shell pwd)/$(PLANFILE)

# Destroy infrastructure
destroy:
	cd $(TF_DIR) && \
	terraform destroy -var-file=$(shell pwd)/$(CONFIG_FILE) -compact-warnings

# Clean up plan files
clean:
	rm -f terraform/plans/*.tfplan

.PHONY: init init-env plan apply destroy clean