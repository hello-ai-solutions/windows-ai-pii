.PHONY: init plan apply destroy test clean test-local ai-proxy

ENV ?= dev

ai-proxy:
	node ai-proxy.js

mitm-proxy:
	mitmdump -s pii_mitm.py --listen-port 8888

test-mitm:
	curl -x localhost:8888 --cacert ~/.mitmproxy/mitmproxy-ca-cert.pem \
		-X POST https://api.openai.com/v1/chat/completions \
		-H "Authorization: Bearer sk-test" \
		-H "Content-Type: application/json" \
		-d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"this is shawn"}]}'

test-openai:
	node test-openai.js

test-local:
	node test-local.js

init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan -var-file="tfvars/$(ENV).tfvars"

apply:
	cd terraform && terraform apply -var-file="tfvars/$(ENV).tfvars" -auto-approve

destroy:
	cd terraform && terraform destroy -var-file="tfvars/$(ENV).tfvars" -auto-approve

test:
	$(eval API_URL := $(shell cd terraform && terraform output -raw api_gateway_url))
	curl -X POST $(API_URL) \
		-H "Content-Type: application/json" \
		-d '{"text":"My name is John Doe and my email is john.doe@example.com"}' \
		| jq .

clean:
	cd terraform && rm -f terraform.tfstate* .terraform.lock.hcl pii-proxy-lambda.zip
	cd terraform && rm -rf .terraform/

dev: init apply test

prod:
	$(MAKE) apply ENV=prod
	$(MAKE) test
