# === CONFIG ===
ENV ?= dev
TF_DIR=terraform/environments/$(ENV)
CONFIG_FILE=terraform/config/$(ENV).tfvars
PLANFILE=terraform/plans/$(ENV).tfplan
ACCOUNT_ID ?= 070503547773

REPO_OWNER ?= your-github-owner
REPO_NAME  ?= your-repository-name

S3_BUCKET ?= terraform-state-$(REPO_OWNER)-$(REPO_NAME)
STATE_KEY=terraform/$(ENV)/terraform.tfstate
LOCK_TABLE ?= terraform-locks-$(ENV)

LAMBDA_BUCKET=lambda-packages-$(ENV)-$(ACCOUNT_ID)
ZIP_FILE=lambda_deployment_package.zip
S3_KEY=lambda/$(ZIP_FILE)

API_URL ?=

TF_LOG ?= error

# === TARGETS ===

.PHONY: init init-env sync-state backend bootstrap lambda-package plan apply destroy clean healthcheck

init: init-env sync-state ## Generate backend.tf and sync remote state

init-env:
	mkdir -p $(TF_DIR)
	echo 'terraform {' > $(TF_DIR)/backend.tf
	echo '  backend "s3" {' >> $(TF_DIR)/backend.tf
	echo '    bucket = "$(S3_BUCKET)"' >> $(TF_DIR)/backend.tf
	echo '    key    = "$(STATE_KEY)"' >> $(TF_DIR)/backend.tf
	echo '    region = "us-east-1"' >> $(TF_DIR)/backend.tf
	echo '    dynamodb_table = "$(LOCK_TABLE)"' >> $(TF_DIR)/backend.tf
	echo '  }' >> $(TF_DIR)/backend.tf
	echo '}' >> $(TF_DIR)/backend.tf
	cd $(TF_DIR) && terraform init -reconfigure

sync-state:
	aws s3 cp s3://$(S3_BUCKET)/$(STATE_KEY) $(TF_DIR)/terraform.tfstate || echo "⚠️ No remote state found. Proceeding..."

bootstrap:
	cd terraform/bootstrap && terraform init && terraform apply -auto-approve -var="environment=$(ENV)"

lambda-package:
	mkdir -p placeholder_lambda
	echo 'def lambda_handler(event, context): return {"statusCode": 200, "body": "Hello from Makefile Lambda"}' > placeholder_lambda/lambda_handler.py
	cd placeholder_lambda && zip -r ../$(ZIP_FILE) .
	aws s3 cp $(ZIP_FILE) s3://$(LAMBDA_BUCKET)/$(S3_KEY)
	@echo "✅ Lambda package uploaded to s3://$(LAMBDA_BUCKET)/$(S3_KEY)"

plan:
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
	cd $(TF_DIR) && \
	TF_LOG=$(TF_LOG) terraform apply -auto-approve \
		-var-file=$(shell pwd)/$(CONFIG_FILE) \
		-var="enabled=true" \
		-var="s3_bucket=$(LAMBDA_BUCKET)" \
		-var="s3_key=$(S3_KEY)" \
		-compact-warnings

destroy:
	cd $(TF_DIR) && \
	TF_LOG=$(TF_LOG) terraform destroy -auto-approve \
		-var-file=$(shell pwd)/$(CONFIG_FILE)

healthcheck:
ifndef API_URL
	$(error API_URL not set. Run with: make healthcheck API_URL=https://your-api-url)
endif
	@echo "🔍 Running healthcheck on $(API_URL)/healthcheck ..."
	@curl --fail --silent --show-error --max-time 10 "$(API_URL)/healthcheck" && echo "✅ Passed" ||_
