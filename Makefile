# Environment and options
ENV=dev
PLAN_OPTS=
APPLY_OPTS=
TF_DIR=terraform/environments/$(ENV)
CONFIG_FILE=terraform/config/$(ENV).tfvars
PLANFILE=terraform/plans/$(ENV).tfplan

# These values mirror what is used in the CI/CD workflow.
# Override these locally if necessary.
REPO_OWNER ?= your-github-owner
REPO_NAME  ?= your-repository-name

# Construct S3 bucket name as in CI/CD
S3_BUCKET ?= terraform-state-$(REPO_OWNER)-$(REPO_NAME)
STATE_KEY=terraform/$(ENV)/terraform.tfstate

# Create necessary directories
init:
	mkdir -p terraform/plans
	mkdir -p terraform/config

# Sync the remote state file from S3 locally
sync-state:
	aws s3 cp s3://$(S3_BUCKET)/$(STATE_KEY) $(TF_DIR)/terraform.tfstate

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

.PHONY: init sync-state init-env plan apply destroy clean
