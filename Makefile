# === CONFIG ===
ENV ?= dev
TF_DIR=terraform/environments/$(ENV)
CONFIG_FILE=terraform/config/$(ENV).tfvars
PLANFILE=terraform/plans/$(ENV).tfplan
ACCOUNT_ID ?= 070503547773

REPO_OWNER ?= $(shell git remote -v | grep origin | head -n 1 | awk -F'[:/]' '{print $(NF-1)}')
REPO_NAME  ?= $(shell git remote -v | grep origin | head -n 1 | awk -F'[:/.]' '{print $(NF-1)}')

S3_BUCKET ?= terraform-state-$(REPO_OWNER)-$(REPO_NAME)
STATE_KEY=terraform/$(ENV)/terraform.tfstate
LOCK_TABLE ?= terraform-locks-$(ENV)

LAMBDA_BUCKET=lambda-packages-$(ENV)-$(ACCOUNT_ID)
ZIP_FILE=lambda_deployment_package.zip
S3_KEY=lambda/$(ZIP_FILE)_$(shell date +%Y%m%d%H%M%S).zip

API_URL ?= $(shell cd $(TF_DIR) && terraform output -raw api_url 2>/dev/null || echo "")

TF_LOG ?= error

# === TARGETS ===

.PHONY: all check-env init init-env sync-state backend bootstrap lambda-package plan apply deploy destroy clean healthcheck

all: check-env init bootstrap lambda-package plan apply healthcheck ## Run the full deployment pipeline

check-env:
	@echo "🚀 Running for environment: $(ENV)"
	@echo "📦 Using account: $(ACCOUNT_ID)"
	@echo "💾 State bucket: $(S3_BUCKET)"
	@echo "📄 Using config: $(CONFIG_FILE)"

init: init-env sync-state ## Generate backend.tf and sync remote state

init-env:
	@echo "🔧 Initializing Terraform environment..."
	mkdir -p $(TF_DIR)
	@echo 'terraform {' > $(TF_DIR)/backend.tf
	@echo '  backend "s3" {' >> $(TF_DIR)/backend.tf
	@echo '    bucket = "$(S3_BUCKET)"' >> $(TF_DIR)/backend.tf
	@echo '    key    = "$(STATE_KEY)"' >> $(TF_DIR)/backend.tf
	@echo '    region = "us-east-1"' >> $(TF_DIR)/backend.tf
	@echo '    dynamodb_table = "$(LOCK_TABLE)"' >> $(TF_DIR)/backend.tf
	@echo '  }' >> $(TF_DIR)/backend.tf
	@echo '}' >> $(TF_DIR)/backend.tf
	cd $(TF_DIR) && terraform init -reconfigure

sync-state:
	aws s3 cp s3://$(S3_BUCKET)/$(STATE_KEY) $(TF_DIR)/terraform.tfstate || echo "⚠️ No remote state found. Proceeding..."

bootstrap:
	@echo "🏗️ Setting up DynamoDB lock table..."
	cd terraform/bootstrap && terraform init && terraform apply -auto-approve -var="environment=$(ENV)"

lambda-package:
	@echo "📦 Creating Lambda deployment package..."
	@if [ -f "create_lambda_package.sh" ]; then \
		chmod +x create_lambda_package.sh && ./create_lambda_package.sh; \
	else \
		mkdir -p placeholder_lambda; \
		echo 'def lambda_handler(event, context): return {"statusCode": 200, "body": "Hello from Makefile Lambda"}' > placeholder_lambda/lambda_handler.py; \
		cd placeholder_lambda && zip -r ../$(ZIP_FILE) .; \
	fi
	
	@echo "☁️ Uploading Lambda package to S3..."
	@aws s3api head-bucket --bucket $(LAMBDA_BUCKET) 2>/dev/null || \
		(echo "⚠️ Lambda bucket does not exist! Infrastructure may need to be deployed first." && exit 1)
	
	aws s3 cp $(ZIP_FILE) s3://$(LAMBDA_BUCKET)/$(S3_KEY)
	@echo "✅ Lambda package uploaded to s3://$(LAMBDA_BUCKET)/$(S3_KEY)"

plan:
	@echo "📝 Planning Terraform changes..."
	mkdir -p $(shell dirname $(PLANFILE))
	cd $(TF_DIR) && \
	TF_LOG=$(TF_LOG) terraform plan \
		-out=$(shell pwd)/$(PLANFILE) \
		-var-file=$(shell pwd)/$(CONFIG_FILE) \
		-var="enabled=true" \
		-var="s3_bucket=$(LAMBDA_BUCKET)" \
		-var="s3_key=$(S3_KEY)" \
		-compact-warnings

apply:
	@echo "🚀 Applying Terraform changes..."
	cd $(TF_DIR) && \
	TF_LOG=$(TF_LOG) terraform apply -auto-approve \
		-var-file=$(shell pwd)/$(CONFIG_FILE) \
		-var="enabled=true" \
		-var="s3_bucket=$(LAMBDA_BUCKET)" \
		-var="s3_key=$(S3_KEY)" \
		-compact-warnings

deploy: lambda-package apply ## Build Lambda package and deploy all infrastructure

destroy:
	@echo "⚠️ Destroying all infrastructure in $(ENV) environment..."
	@read -p "Are you sure? (y/N) " confirm && [ "$$confirm" = "y" ] || exit 1
	cd $(TF_DIR) && \
	TF_LOG=$(TF_LOG) terraform destroy -auto-approve \
		-var-file=$(shell pwd)/$(CONFIG_FILE)

healthcheck:
	@echo "🔍 Running healthcheck..."
	@if [ -z "$(API_URL)" ]; then \
		echo "⚠️ API_URL not set. Attempting to retrieve from Terraform outputs..."; \
		API_URL=$$(cd $(TF_DIR) && terraform output -raw api_url 2>/dev/null); \
		if [ -z "$$API_URL" ]; then \
			echo "❌ Could not determine API_URL. Please set manually: make healthcheck API_URL=https://your-api-url"; \
			exit 1; \
		fi; \
		echo "✅ Found API URL: $$API_URL"; \
	fi; \
	echo "🔍 Running healthcheck on $(API_URL)/healthcheck ..."; \
	curl --fail --silent --show-error --max-time 10 "$(API_URL)/healthcheck" && echo "✅ Passed" || echo "❌ Failed"

clean:
	@echo "🧹 Cleaning up local files..."
	rm -f $(ZIP_FILE)
	rm -rf placeholder_lambda

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help